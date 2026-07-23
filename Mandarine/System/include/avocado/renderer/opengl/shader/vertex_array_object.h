#pragma once
#include <OpenGLES/ES3/gl.h>

class VertexArrayObject {
    GLuint id;

   public:
    static GLuint currentId;

    VertexArrayObject();
    ~VertexArrayObject();

    void bind();
    GLuint get();
};
