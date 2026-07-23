#pragma once
#include <OpenGLES/ES3/gl.h>

class Texture {
    GLuint id;
    int width;
    int height;
    GLint dataFormat;
    GLenum type;

    bool success;

   public:
    Texture(int width, int height, GLint internalFormat, GLint dataFormat, GLenum type, bool filter);
    ~Texture();

    void update(const void* data);
    void bind(int sampler = 0);
    GLuint get();
    int getWidth();
    int getHeight();
    bool isCreated();
};
