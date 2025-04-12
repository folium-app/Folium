//
//  NewGrapeObjC.mm
//  NewGrape
//
//  Created by Jarrod Norwell on 4/3/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

#import "NewGrapeObjC.h"

#include "melonDS/Platform.h"
#include "melonDS/NDS.h"
#include "melonDS/SPU.h"
#include "melonDS/GPU.h"
#include "melonDS/AREngine.h"

#include "melonDS/Config.h"

#import "DirectoryManager.h"

#include <fstream>
#include <vector>

CVPixelBufferRef scaledPixelBuffer(CVPixelBufferRef pixelBuffer, CGSize size) {
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    CIContext *context = [CIContext contextWithOptions:NULL];
    
    CGSize inputSize = ciImage.extent.size;
    
    CGFloat widthScale = size.width / inputSize.width;
    CGFloat heightScale = size.height / inputSize.height;
    CGFloat scaleFactor = MIN(widthScale, heightScale);
    
    CGSize scaledSize = CGSizeMake(inputSize.width * scaleFactor, inputSize.height * scaleFactor);
    
    NSDictionary *pixelBufferAttributes = @{
        (NSString *)kCVPixelBufferCGImageCompatibilityKey: @YES,
        (NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES
    };
    
    CVPixelBufferRef scaledPixelBuffer;
    CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)pixelBufferAttributes, &scaledPixelBuffer);
    
    CVPixelBufferLockBaseAddress(scaledPixelBuffer, kCVPixelBufferLock_ReadOnly);
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    CIImage *scaledImage = [ciImage imageByApplyingTransform:scaleTransform];
    
    CGFloat offsetX = (size.width - scaledSize.width) / 2.0;
    CGFloat offsetY = (size.height - scaledSize.height) / 2.0;
    CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(offsetX, offsetY);
    CIImage *centeredImage = [scaledImage imageByApplyingTransform:translateTransform];
    
    [context render:centeredImage toCVPixelBuffer:scaledPixelBuffer];
    
    CVPixelBufferUnlockBaseAddress(scaledPixelBuffer, kCVPixelBufferLock_ReadOnly);
    
    return scaledPixelBuffer;
}

@interface Camera : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {
    AVCaptureDevice *device;
    AVCaptureSession *session;
    AVCaptureDeviceInput *input;
    AVCaptureVideoDataOutput *output;
    
    BOOL isYUV;
    CGFloat _width, _height;
    
    std::vector<uint32_t> framebuffer;
}

+(Camera *) sharedInstance;

-(void) stop;
-(void) start;

-(void) resolution:(CGSize)resolution;
-(void) yuv:(BOOL)yuv;

-(std::vector<uint32_t>) frame;
@end

@implementation Camera
-(Camera *) init {
    if (self = [super init]) {
        session = [[AVCaptureSession alloc] init];
        [session setSessionPreset:AVCaptureSessionPresetHigh];
        
        NSArray<AVCaptureDevice *> *devices = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[
            AVCaptureDeviceTypeBuiltInWideAngleCamera
        ] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified].devices;
        
        [devices enumerateObjectsUsingBlock:^(AVCaptureDevice *obj, NSUInteger idx, BOOL *stop) {
            if ([obj position] == AVCaptureDevicePositionFront) {
                device = obj;
                *stop = TRUE;
            }
        }];
    } return self;
}

+(Camera *) sharedInstance {
    static Camera *sharedInstance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void) stop {
    if ([session isRunning])
        [session stopRunning];
    
    [session removeInput:input];
    [session removeOutput:output];
}

-(void) start {
    [device lockForConfiguration:NULL];
    // configure
    [device setActiveVideoMinFrameDuration:CMTimeMake(1, 30)];
    [device setActiveVideoMaxFrameDuration:CMTimeMake(1, 30)];
    [device unlockForConfiguration];
    
    input = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
    
    if ([session canAddInput:input])
        [session addInput:input];
    
    output = [[AVCaptureVideoDataOutput alloc] init];
    
    NSDictionary *settings = @{
        (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)
    };
    
    [output setVideoSettings:settings];
    [output setAlwaysDiscardsLateVideoFrames:YES];
    [output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    if ([session canAddOutput:output])
        [session addOutput:output];
    
    if (![session isRunning])
        [session startRunning];
}

-(void) resolution:(CGSize)resolution {
    _width = resolution.width;
    _height = resolution.height;
    framebuffer.resize(_width * _height);
}

-(void) yuv:(BOOL)yuv {
    isYUV = yuv;
}

-(std::vector<uint32_t>) frame {
    return framebuffer;
}

static void RGBtoYUV(uint8_t r, uint8_t g, uint8_t b, uint8_t& y, uint8_t& u, uint8_t& v) {
    int Y = (  66 * r + 129 * g +  25 * b + 128) >> 8;
    int U = ( -38 * r -  74 * g + 112 * b + 128) >> 8;
    int V = ( 112 * r -  94 * g -  18 * b + 128) >> 8;
    y = std::clamp(Y +  16, 0, 255);
    u = std::clamp(U + 128, 0, 255);
    v = std::clamp(V + 128, 0, 255);
}

-(void) captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    @autoreleasepool {
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        if (!UIDeviceOrientationIsFlat(orientation))
            [connection setVideoOrientation:(AVCaptureVideoOrientation)orientation];
        else
            [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        
        CVPixelBufferRef ref = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferRef pixelBuffer = scaledPixelBuffer(ref, {_width, _height});
        
        CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
        
        uint8_t *bgraData = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);
        size_t bgraStride = CVPixelBufferGetBytesPerRow(pixelBuffer);
        size_t width = CVPixelBufferGetWidth(pixelBuffer);
        size_t height = CVPixelBufferGetHeight(pixelBuffer);
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
        
        if (!isYUV) {
            std::vector<uint32_t> rgb565Buffer(_width * _height);
            
            for (size_t y = 0; y < _height; ++y) {
                uint8_t *srcRow = bgraData + y * bgraStride;
                for (size_t x = 0; x < _width; ++x) {
                    uint8_t b = srcRow[x * 4 + 0];
                    uint8_t g = srcRow[x * 4 + 1];
                    uint8_t r = srcRow[x * 4 + 2];
                    uint8_t a = srcRow[x * 4 + 3];
                    
                    // Pack as RGBA8888
                    rgb565Buffer.at(y * _width + x) = (r << 24) | (g << 16) | (b << 8) | a;
                }
            }
            
            memcpy(framebuffer.data(), rgb565Buffer.data(), _width * _height * sizeof(uint32_t));
        } else {
            std::vector<uint32_t> yuv422(_width * _height / 2);
            
            for (size_t y = 0; y < _height; ++y) {
                uint8_t *src = bgraData + y * bgraStride;
                
                for (size_t x = 0; x < _width; x += 2) {
                    uint8_t b0 = src[x * 4 + 0];
                    uint8_t g0 = src[x * 4 + 1];
                    uint8_t r0 = src[x * 4 + 2];
                    
                    uint8_t b1 = src[(x + 1) * 4 + 0];
                    uint8_t g1 = src[(x + 1) * 4 + 1];
                    uint8_t r1 = src[(x + 1) * 4 + 2];
                    
                    uint8_t y0, u0, v0;
                    uint8_t y1, u1, v1;
                    
                    RGBtoYUV(r0, g0, b0, y0, u0, v0);
                    RGBtoYUV(r1, g1, b1, y1, u1, v1);
                    
                    uint8_t u = (u0 + u1) / 2;
                    uint8_t v = (v0 + v1) / 2;
                    
                    uint32_t packed = (v << 24) | (y1 << 16) | (u << 8) | y0;
                    yuv422.push_back(packed);
                }
            }
            
            memcpy(framebuffer.data(), yuv422.data(), _width * _height * sizeof(uint32_t));
        }
        
        CVPixelBufferRelease(pixelBuffer);
    }
}
@end

/*
 
 */

typedef NS_ENUM(NSUInteger, ConsoleType) {
    ConsoleTypeNDS = 0,
    ConsoleTypeDSi
};

@implementation NewGrapeObjC
+(NewGrapeObjC *) sharedInstance {
    static NewGrapeObjC *sharedInstance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void) insertCartridge:(NSURL *)url {
    inputs = 0;
    
    Config::Load();
    GPU::InitRenderer(0);
    
    Config::BIOS7Path = [[sysdataDirectory() URLByAppendingPathComponent:@"bios7.bin"].path UTF8String];
    Config::BIOS9Path = [[sysdataDirectory() URLByAppendingPathComponent:@"bios9.bin"].path UTF8String];
    Config::FirmwarePath = [[sysdataDirectory() URLByAppendingPathComponent:@"firmware.bin"].path UTF8String];
    
    BOOL (^fileExists)(NSURL *) = ^BOOL(NSURL *url) {
        return [[NSFileManager defaultManager] fileExistsAtPath:url.path];
    };
    
    NSURL *bios7i = [sysdataDirectory() URLByAppendingPathComponent:@"bios7i.bin"];
    NSURL *bios9i = [sysdataDirectory() URLByAppendingPathComponent:@"bios9i.bin"];
    NSURL *firmwarei = [sysdataDirectory() URLByAppendingPathComponent:@"firmwarei.bin"];
    NSURL *nandi = [sysdataDirectory() URLByAppendingPathComponent:@"nandi.bin"];
    
    if (fileExists(bios7i) && fileExists(bios9i) && fileExists(firmwarei) && fileExists(nandi)) {
        NDS::SetConsoleType([[NSUserDefaults standardUserDefaults] boolForKey:@"grape.dsiMode"] ? ConsoleType::ConsoleTypeDSi : ConsoleType::ConsoleTypeNDS);
        
        Config::DSiBIOS7Path = [bios7i.path UTF8String];
        Config::DSiBIOS9Path = [bios9i.path UTF8String];
        Config::DSiFirmwarePath = [firmwarei.path UTF8String];
        Config::DSiNANDPath = [nandi.path UTF8String];
    } else
        NDS::SetConsoleType(ConsoleType::ConsoleTypeNDS);
    
    Config::DirectBoot = [[NSUserDefaults standardUserDefaults] boolForKey:@"grape.directBoot"];
    Config::ExternalBIOSEnable = YES;
    
    NDS::Init();
    
    GPU::RenderSettings settings;
    settings.Soft_Threaded = YES;

    GPU::SetRenderSettings(0, settings);
    
    NDS::Reset();
    
    _url = url;
    NSData *data = [NSData dataWithContentsOfURL:url];
    NDS::LoadCart((const u8*)data.bytes, (u32)data.length, nullptr, 0);
    NDS::Start();
}

-(void) step {
    uint32_t _inputs = inputs;
    uint32_t inputsMask = 0xFFF;
    
    uint16_t sanitizedInputs = inputsMask ^ _inputs;
    NDS::SetKeyMask(sanitizedInputs);
    
    NDS::RunFrame();
    
    if (auto buffer = [[NewGrapeObjC sharedInstance] ab]) {
        static int16_t buf[0x1000];
        u32 availableBytes = SPU::GetOutputSize();
        availableBytes = MAX(availableBytes, (u32)(sizeof(buf) / (2 * sizeof(int16_t))));
        
        int samples = SPU::ReadOutput(buf, availableBytes);
        
        buffer(buf, samples);
    }
    
    if (auto buffers = [[NewGrapeObjC sharedInstance] fbs])
        buffers(GPU::Framebuffer[GPU::FrontBuffer][0], GPU::Framebuffer[GPU::FrontBuffer][1]);
}

-(void) stop {
    NDS::Stop();
}

-(void) touchBeganAtPoint:(CGPoint)point {
    NDS::TouchScreen(point.x, point.y);
}

-(void) touchEnded {
    NDS::TouchScreen(0, 0);
    NDS::ReleaseScreen();
}

-(void) touchMovedAtPoint:(CGPoint)point {
    NDS::TouchScreen(point.x, point.y);
}

-(void) button:(uint32_t)button pressed:(BOOL)pressed {
    if (pressed)
        inputs |= button;
    else
        inputs &= ~button;
}

-(BOOL) loadState {
    NSURL *directory = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:@"Grape"];
    NSString *path = [NSString stringWithFormat:@"%@/states/%@.state", [directory path], [[_url URLByDeletingPathExtension] lastPathComponent]];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        Savestate* saveState = new Savestate(std::string{[url.path UTF8String]}, false);
        auto result = NDS::DoSavestate(saveState);
        delete saveState;
        return result;
    } else {
        return NO;
    }
}

-(BOOL) saveState {
    NSURL *directory = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:@"Grape"];
    NSString *path = [NSString stringWithFormat:@"%@/states/%@.state", [directory path], [[_url URLByDeletingPathExtension] lastPathComponent]];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
    Savestate* saveState = new Savestate(std::string{[url.path UTF8String]}, true);
    auto result = NDS::DoSavestate(saveState);
    delete saveState;
    return result;
}

-(void) updateSettings {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    Config::DirectBoot = [userDefaults boolForKey:@"grape.directBoot"];
    
    NDS::SetConsoleType([userDefaults boolForKey:@"grape.dsiMode"] ? ConsoleType::ConsoleTypeDSi : ConsoleType::ConsoleTypeNDS);
}
@end


// MARK: Platform
// Taken from Delta
namespace Platform
{
    int IPCInstanceID;

void StopEmu() {}

    int InstanceID()
    {
        return IPCInstanceID;
    }

    std::string InstanceFileSuffix()
    {
        int inst = IPCInstanceID;
        if (inst == 0) return "";

        char suffix[16] = {0};
        snprintf(suffix, 15, ".%d", inst+1);
        return suffix;
    }

    int GetConfigInt(ConfigEntry entry)
    {
        const int imgsizes[] = {0, 256, 512, 1024, 2048, 4096};

        switch (entry)
        {
            default: break;
    #ifdef JIT_ENABLED
        case JIT_MaxBlockSize: return Config::JIT_MaxBlockSize;
    #endif

        case DLDI_ImageSize: return imgsizes[Config::DLDISize];

        case DSiSD_ImageSize: return imgsizes[Config::DSiSDSize];

        case Firm_Language: return Config::FirmwareLanguage;
        case Firm_BirthdayMonth: return Config::FirmwareBirthdayMonth;
        case Firm_BirthdayDay: return Config::FirmwareBirthdayDay;
        case Firm_Color: return Config::FirmwareFavouriteColour;

        case AudioBitrate: return Config::AudioBitrate;
        }

        return 0;
    }

    bool GetConfigBool(ConfigEntry entry)
    {
        switch (entry)
        {
            default: break;
    #ifdef JIT_ENABLED
        case JIT_Enable: return Config::JIT_Enable != 0;
        case JIT_LiteralOptimizations: return Config::JIT_LiteralOptimisations != 0;
        case JIT_BranchOptimizations: return Config::JIT_BranchOptimisations != 0;
        case JIT_FastMemory: return Config::JIT_FastMemory != 0;
    #endif

        case ExternalBIOSEnable: return Config::ExternalBIOSEnable != 0;

        case DLDI_Enable: return Config::DLDIEnable != 0;
        case DLDI_ReadOnly: return Config::DLDIReadOnly != 0;
        case DLDI_FolderSync: return Config::DLDIFolderSync != 0;

        case DSiSD_Enable: return Config::DSiSDEnable != 0;
        case DSiSD_ReadOnly: return Config::DSiSDReadOnly != 0;
        case DSiSD_FolderSync: return Config::DSiSDFolderSync != 0;

        case Firm_OverrideSettings: return Config::FirmwareOverrideSettings != 0;
        }

        return false;
    }

    std::string GetConfigString(ConfigEntry entry)
    {
        switch (entry)
        {
            default: break;
        case BIOS9Path: return Config::BIOS9Path;
        case BIOS7Path: return Config::BIOS7Path;
        case FirmwarePath: return Config::FirmwarePath;

        case DSi_BIOS9Path: return Config::DSiBIOS9Path;
        case DSi_BIOS7Path: return Config::DSiBIOS7Path;
        case DSi_FirmwarePath: return Config::DSiFirmwarePath;
        case DSi_NANDPath: return Config::DSiNANDPath;

        case DLDI_ImagePath: return Config::DLDISDPath;
        case DLDI_FolderPath: return Config::DLDIFolderPath;

        case DSiSD_ImagePath: return Config::DSiSDPath;
        case DSiSD_FolderPath: return Config::DSiSDFolderPath;

        case Firm_Username: return Config::FirmwareUsername;
        case Firm_Message: return Config::FirmwareMessage;
        }

        return "";
    }

    bool GetConfigArray(ConfigEntry entry, void* data)
    {
        switch (entry)
        {
            default: break;
        case Firm_MAC:
            {
                std::string& mac_in = Config::FirmwareMAC;
                u8* mac_out = (u8*)data;

                int o = 0;
                u8 tmp = 0;
                for (int i = 0; i < 18; i++)
                {
                    char c = mac_in[i];
                    if (c == '\0') break;

                    int n;
                    if      (c >= '0' && c <= '9') n = c - '0';
                    else if (c >= 'a' && c <= 'f') n = c - 'a' + 10;
                    else if (c >= 'A' && c <= 'F') n = c - 'A' + 10;
                    else continue;

                    if (!(o & 1))
                        tmp = n;
                    else
                        mac_out[o >> 1] = n | (tmp << 4);

                    o++;
                    if (o >= 12) return true;
                }
            }
            return false;
        }

        return false;
    }
    
    FILE* OpenFile(std::string path, std::string mode, bool mustexist)
    {
        FILE* ret;
        
        if (mustexist)
        {
            ret = fopen(path.c_str(), "rb");
            if (ret) ret = freopen(path.c_str(), mode.c_str(), ret);
        }
        else
            ret = fopen(path.c_str(), mode.c_str());
        
        NSLog(@"file = %s (%d)", path.c_str(), ret != nullptr);
        
        return ret;
    }
    
    FILE* OpenLocalFile(std::string path, std::string mode)
    {
        NSURL *coreDirectoryURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:@"Grape"];
        NSURL *relativeURL = [coreDirectoryURL URLByAppendingPathComponent:@(path.c_str())];
                
        NSURL *fileURL = nil;
        if ([[NSFileManager defaultManager] fileExistsAtPath:relativeURL.path])
        {
            fileURL = relativeURL;
        }
        else
        {
            fileURL = [NSURL fileURLWithPath:@(path.c_str())];
        }
        
        return OpenFile(fileURL.fileSystemRepresentation, mode.c_str());
    }
    
    Thread* Thread_Create(std::function<void()> func)
    {
        NSThread *thread = [[NSThread alloc] initWithBlock:^{
            func();
        }];
        
        thread.name = @"MelonDS - Rendering";
        thread.qualityOfService = NSQualityOfServiceUserInitiated;
        
        [thread start];
        
        return (Thread *)CFBridgingRetain(thread);
    }
    
    void Thread_Free(Thread *thread)
    {
        NSThread *nsThread = (NSThread *)CFBridgingRelease(thread);
        [nsThread cancel];
    }
    
    void Thread_Wait(Thread *thread)
    {
        NSThread *nsThread = (__bridge NSThread *)thread;
        while (nsThread.isExecuting)
        {
            continue;
        }
    }
    
    Semaphore *Semaphore_Create()
    {
        dispatch_semaphore_t dispatchSemaphore = dispatch_semaphore_create(0);
        return (Semaphore *)CFBridgingRetain(dispatchSemaphore);
    }
    
    void Semaphore_Free(Semaphore *semaphore)
    {
        CFRelease(semaphore);
    }
    
    void Semaphore_Reset(Semaphore *semaphore)
    {
        dispatch_semaphore_t dispatchSemaphore = (__bridge dispatch_semaphore_t)semaphore;
        while (dispatch_semaphore_wait(dispatchSemaphore, DISPATCH_TIME_NOW) == 0)
        {
            continue;
        }
    }
    
    void Semaphore_Wait(Semaphore *semaphore)
    {
        dispatch_semaphore_t dispatchSemaphore = (__bridge dispatch_semaphore_t)semaphore;
        dispatch_semaphore_wait(dispatchSemaphore, DISPATCH_TIME_FOREVER);
    }

    void Semaphore_Post(Semaphore *semaphore, int count)
    {
        dispatch_semaphore_t dispatchSemaphore = (__bridge dispatch_semaphore_t)semaphore;
        for (int i = 0; i < count; i++)
        {
            dispatch_semaphore_signal(dispatchSemaphore);
        }
    }

    Mutex *Mutex_Create()
    {
        // NSLock is too slow for real-time audio, so use pthread_mutex_t directly.
        
        pthread_mutex_t *mutex = (pthread_mutex_t *)malloc(sizeof(pthread_mutex_t));
        pthread_mutex_init(mutex, NULL);
        return (Mutex *)mutex;
    }

    void Mutex_Free(Mutex *m)
    {
        pthread_mutex_t *mutex = (pthread_mutex_t *)m;
        pthread_mutex_destroy(mutex);
        free(mutex);
    }

    void Mutex_Lock(Mutex *m)
    {
        pthread_mutex_t *mutex = (pthread_mutex_t *)m;
        pthread_mutex_lock(mutex);
    }

    void Mutex_Unlock(Mutex *m)
    {
        pthread_mutex_t *mutex = (pthread_mutex_t *)m;
        pthread_mutex_unlock(mutex);
    }
    
    void *GL_GetProcAddress(const char* proc)
    {
        return NULL;
    }
    
    bool MP_Init()
    {
        return false;
    }
    
    void MP_DeInit()
    {
    }

    void MP_Begin()
    {
    }

    void MP_End()
    {
    }
    
    int MP_SendPacket(u8* data, int len, u64 timestamp)
    {
        return 0;
    }
    
    int MP_RecvPacket(u8* data, u64* timestamp)
    {
        return 0;
    }

    int MP_SendCmd(u8* data, int len, u64 timestamp)
    {
        return 0;
    }

    int MP_SendReply(u8* data, int len, u64 timestamp, u16 aid)
    {
        return 0;
    }

    int MP_SendAck(u8* data, int len, u64 timestamp)
    {
        return 0;
    }

    int MP_RecvHostPacket(u8* data, u64* timestamp)
    {
        return 0;
    }

    u16 MP_RecvReplies(u8* data, u64 timestamp, u16 aidmask)
    {
        return 0;
    }
    
    bool LAN_Init()
    {
        return false;
    }
    
    void LAN_DeInit()
    {
    }
    
    int LAN_SendPacket(u8* data, int len)
    {
        return 0;
    }
    
    int LAN_RecvPacket(u8* data)
    {
        return 0;
    }

    void Mic_Prepare()
    {
        //if (![MelonDSEmulatorBridge.sharedBridge isMicrophoneEnabled] || [MelonDSEmulatorBridge.sharedBridge.audioEngine isRunning])
        //{
        //    return;
        //}
        
        //NSError *error = nil;
        //if (![MelonDSEmulatorBridge.sharedBridge.audioEngine startAndReturnError:&error])
        //{
        //    NSLog(@"Failed to start listening to microphone. %@", error);
        //}
    }

    void WriteNDSSave(const u8* savebytes, u32 savelen, u32 writeoffset, u32 writelen)
    {
        //TODO: Flush to disk automatically
        //NSData *saveData = [NSData dataWithBytes:savebytes length:savelen];
        //MelonDSEmulatorBridge.sharedBridge.saveData = saveData;
    }

    void WriteGBASave(const u8* savebytes, u32 savelen, u32 writeoffset, u32 writelen)
    {
        //TODO: Flush to disk automatically
        //NSData *saveData = [NSData dataWithBytes:savebytes length:savelen];
        //MelonDSEmulatorBridge.sharedBridge.gbaSaveData = saveData;
    }

    void Camera_Start(int num)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[Camera sharedInstance] start];
        });
    }

    void Camera_Stop(int num)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[Camera sharedInstance] stop];
        });
    }

    void Camera_CaptureFrame(int num, u32* frame, int width, int height, bool yuv)
    {
        NSLog(@"%s, %i, %i, %i", __FUNCTION__, width, height, yuv);
        [[Camera sharedInstance] resolution:CGSizeMake(width, height)];
        [[Camera sharedInstance] yuv:yuv];
        
        auto data = [[Camera sharedInstance] frame];
        *frame = *data.data();
    }
}
