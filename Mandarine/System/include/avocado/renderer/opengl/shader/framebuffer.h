#pragma once
#include <OpenGLES/ES3/gl.h>

class Framebuffer {
    GLuint id;

   public:
    static GLuint currentId;

    Framebuffer(GLuint colorTexture);
    ~Framebuffer();

    void bind();
    GLuint get();
};
