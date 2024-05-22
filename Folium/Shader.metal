//
//  Shader.metal
//  Folium
//
//  Created by Jarrod Norwell on 17/5/2024.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 textureCoordinate;
};

vertex VertexOut vertexShader(uint vertexID [[vertex_id]]) {
    constexpr float2 positions[4] = { { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } };
    VertexOut out;
    out.position = float4(positions[vertexID], 0.0, 1.0);
    out.position.y *= -1;
    out.textureCoordinate = positions[vertexID] * 0.5 + 0.5; // Normalize texture coordinates
    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]],
                               texture2d<float, access::sample> texture [[texture(0)]]) {
    constexpr sampler textureSampler(mip_filter::nearest, mag_filter::nearest);
    return texture.sample(textureSampler, in.textureCoordinate);
}
