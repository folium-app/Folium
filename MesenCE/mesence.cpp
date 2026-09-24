//
//  mesence.cpp
//  MesenCE
//
//  Created by Jarrod Norwell on 9/9/2026.
//

#include "mesence.h"

#include "Shared/EmuSettings.h"
#include "Shared/Audio/SoundMixer.h"
#include "Shared/Video/VideoRenderer.h"

// MARK: Renderer
iOSRenderer::iOSRenderer(std::unique_ptr<Emulator>& emulator, uint32_t height, uint32_t width) : emulator{emulator} {
    buffers.first.resize(height * width);
    buffers.second.resize(height * width);
    
    dimensions.first.store(height);
    dimensions.second.store(width);
    
    emulator->GetVideoRenderer()->RegisterRenderingDevice(this);
}

iOSRenderer::~iOSRenderer() {
    emulator->GetVideoRenderer()->UnregisterRenderingDevice(this);
}

void iOSRenderer::UpdateFrame(RenderedFrame& frame) {
    std::lock_guard<std::mutex> lock{mutex};
    
    uint32_t height{frame.Height};
    uint32_t width{frame.Width};
    
    uint32_t size{dimensions.first.load() * dimensions.second.load()};
    if (buffers.first.size() != size)
        buffers.first.resize(size);
    
    std::memcpy(buffers.first.data(), frame.FrameBuffer, size * sizeof(uint32_t));
    
    dimensions.first.store(height);
    dimensions.second.store(width);
    
    dirty.store(true, std::memory_order_release);
}

void iOSRenderer::ClearFrame() {
    std::lock_guard<std::mutex> lock{mutex};
    
    std::fill(buffers.first.begin(), buffers.first.end(), 0x00);
    dirty.store(true, std::memory_order_release);
}

void iOSRenderer::Render(RenderSurfaceInfo& /*emuHud*/, RenderSurfaceInfo& /*scriptHud*/) {}

bool iOSRenderer::GetFrameIfReady(std::vector<uint32_t>& out_b, uint32_t& out_h, uint32_t& out_w) {
    if (!dirty.load(std::memory_order_acquire))
        return false;

    std::lock_guard<std::mutex> lock{mutex};
    
    if (!dirty.load(std::memory_order_relaxed))
        return false;

    out_h = dimensions.first.load();
    out_w = dimensions.second.load();
    
    uint32_t size{out_h * out_w};
    
    if (buffers.second.size() != size)
        buffers.second.resize(size);
    
    if (out_b.size() < size)
        out_b.resize(size);
    
    std::swap(buffers.first, buffers.second);
    
    dirty.store(false, std::memory_order_release);

    std::memcpy(out_b.data(), buffers.second.data(), size * sizeof(uint32_t));
    
    return true;
}

// MARK: Sink
iOSSink::iOSSink(std::unique_ptr<Emulator>& emulator, uint32_t sample_rate) : emulator{emulator} {
    auto& audio_config = emulator->GetSettings()->GetAudioConfig();
    audio_latency = audio_config.AudioLatency;
    
    if (sample_rate == -1)
        Initialize(audio_config.SampleRate, false);
    else
        Initialize(sample_rate, false);
    emulator->GetSoundMixer()->RegisterAudioDevice(this);
}

iOSSink::~iOSSink() {
    Release();
}

void iOSSink::Pause() {
    SDL_PauseAudioStreamDevice(stream);
}

void iOSSink::Play(int16_t* out_b, uint32_t sample_count, uint32_t sample_rate, bool stereo) {
    uint32_t bytesPerSample = 2 * (stereo ? 2 : 1);
    uint32_t latency = emulator->GetSettings()->GetAudioConfig().AudioLatency;
    
    std::array<bool, 3> checks{
        _sampleRate == sample_rate,
        _isStereo == stereo,
        audio_latency == latency
    };
    
    if (std::any_of(checks.begin(), checks.end(), [](bool check) { return !check; })) {
        Release();
        Initialize(sample_rate, stereo);
    }

    WriteToBuffer(reinterpret_cast<uint8_t*>(out_b), sample_count * bytesPerSample);
    
    int32_t playWriteByteLatency = positions.second - positions.first;
    if(playWriteByteLatency < 0)
        playWriteByteLatency = _bufferSize - positions.first + positions.second;

    int32_t byteLatency = (int32_t)((float)(sample_rate * latency) / 1000.0f * bytesPerSample);
    if(playWriteByteLatency > byteLatency)
        SDL_ResumeAudioStreamDevice(stream);
}

void iOSSink::Stop() {
    Pause();

    positions.first = positions.second = 0;
    
    ResetStats();
}

void iOSSink::ProcessEndOfFrame() {
    ProcessLatency(positions.first, positions.second);
    
    uint32_t emulationSpeed = emulator->GetSettings()->GetEmulationSpeed();
    std::array<bool, 4> checks{
        _averageLatency > 0,
        emulationSpeed <= 100,
        emulationSpeed > 0,
        std::abs(_averageLatency - emulator->GetSettings()->GetAudioConfig().AudioLatency) > 50
    };

    
    if (std::all_of(checks.begin(), checks.end(), [](bool check) { return check; }))
        Stop();
}

bool iOSSink::Initialize(uint32_t sample_rate, bool stereo) {
    if (!SDL_Init(SDL_INIT_AUDIO))
        return false;

    _sampleRate = sample_rate;
    _isStereo = stereo;
    audio_latency = emulator->GetSettings()->GetAudioConfig().AudioLatency;

    int bytesPerSample = 2 * (stereo ? 2 : 1);
    int32_t requestedByteLatency = (int32_t)((float)(sample_rate * audio_latency) / 1000.0f * bytesPerSample);
    _bufferSize = (int32_t)std::ceil((double)requestedByteLatency * 2 / 0x10000) * 0x10000;
    
    buffer.resize(_bufferSize);
    std::fill(buffer.begin(), buffer.end(), 0);

    SDL_AudioSpec spec;
    SDL_zero(spec);
    
    spec.format = SDL_AUDIO_S16;
    spec.channels = stereo ? 2 : 1;
    spec.freq = sample_rate;
    
    stream = SDL_OpenAudioDeviceStream(SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK, &spec, &iOSSink::Callback, this);

    positions.first = positions.second = 0;

    return true;
}

void iOSSink::Release() {
    _bufferSize = 0;
    buffer.clear();
}

void iOSSink::Callback(void* userdata, SDL_AudioStream* stream, int additional, int total) {
    iOSSink* soundManager = static_cast<iOSSink*>(userdata);

    std::vector<uint8_t> data(total);
    soundManager->ReadFromBuffer(data.data(), total);
    
    SDL_PutAudioStreamData(soundManager->stream, data.data(), total);
}

// TODO: clean up ReadFromBuffer, WriteToBuffer
void iOSSink::ReadFromBuffer(uint8_t* output, uint32_t len)
{
    if(positions.first + len < _bufferSize) {
        memcpy(output, buffer.data() + positions.first, len);
        positions.first += len;
    } else {
        int remainingBytes = (_bufferSize - positions.first);
        memcpy(output, buffer.data() + positions.first, remainingBytes);
        memcpy(output + remainingBytes, buffer.data(), len - remainingBytes);
        positions.first = len - remainingBytes;
    }

    if(positions.first >= positions.second && positions.first - positions.second < _bufferSize / 2) {
        _bufferUnderrunEventCount++;
    }
}

void iOSSink::WriteToBuffer(uint8_t* input, uint32_t len)
{
    if(positions.second + len < _bufferSize) {
        memcpy(buffer.data() + positions.second, input, len);
        positions.second += len;
    } else {
        int remainingBytes = _bufferSize - positions.second;
        memcpy(buffer.data() + positions.second, input, remainingBytes);
        memcpy(buffer.data(), ((uint8_t*)input) + remainingBytes, len - remainingBytes);
        positions.second = len - remainingBytes;
    }
}
