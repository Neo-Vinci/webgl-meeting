common = require '../common/common'
clear = require('gl-clear') { color: [0.1, 0.1, 0.1, 1.0] }
{ vec3, mat4 } = require 'gl-matrix'

vShaderSource = """
    attribute   vec4 a_Position;
    attribute   vec4 a_Color;
    uniform     mat4 u_ViewMatrix;
    uniform     mat4 u_ProjMatrix;
    varying     vec4 v_Color;
    void main() {
        gl_Position = u_ProjMatrix * u_ViewMatrix * a_Position;
        v_Color = a_Color;
    }
"""

fShaderSource = """
    precision   mediump float;
    varying     vec4    v_Color;
    void main() {
        gl_FragColor = v_Color;
    }
"""

vertexNum = 0
u_ProjMatrix = null

initMatrix = (gl) ->
    u_ViewMatrix = gl.getUniformLocation gl.program, 'u_ViewMatrix'
    u_ProjMatrix = gl.getUniformLocation gl.program, 'u_ProjMatrix'
    if !u_ViewMatrix or !u_ProjMatrix
        console.log 'Failed to get the storage locations of u_ViewMatrix and/or u_ProjMatrix'
        return

    viewMatrix = mat4.create()
    eye = vec3.fromValues 0, 0, 5
    center = vec3.fromValues 0, 0, -100
    up = vec3.fromValues 0, 1, 0
    # (out, eye, center, up)
    mat4.lookAt viewMatrix, eye, center, up

    gl.uniformMatrix4fv u_ViewMatrix, false, viewMatrix

initVertexBuffers = (gl) ->
    verticesColors = new Float32Array [
        # Three triangles on the right side
        0.75,  1.0,  -4.0,  0.4,  1.0,  0.4, # The back green one
        0.25, -1.0,  -4.0,  0.4,  1.0,  0.4,
        1.25, -1.0,  -4.0,  1.0,  0.4,  0.4,

        0.75,  1.0,  -2.0,  1.0,  1.0,  0.4, # The middle yellow one
        0.25, -1.0,  -2.0,  1.0,  1.0,  0.4,
        1.25, -1.0,  -2.0,  1.0,  0.4,  0.4,

        0.75,  1.0,   0.0,  0.4,  0.4,  1.0,  # The front blue one
        0.25, -1.0,   0.0,  0.4,  0.4,  1.0,
        1.25, -1.0,   0.0,  1.0,  0.4,  0.4,

        # Three triangles on the left side
        -0.75,  1.0,  -4.0,  0.4,  1.0,  0.4, # The back green one
        -1.25, -1.0,  -4.0,  0.4,  1.0,  0.4,
        -0.25, -1.0,  -4.0,  1.0,  0.4,  0.4,

        -0.75,  1.0,  -2.0,  1.0,  1.0,  0.4, # The middle yellow one
        -1.25, -1.0,  -2.0,  1.0,  1.0,  0.4,
        -0.25, -1.0,  -2.0,  1.0,  0.4,  0.4,

        -0.75,  1.0,   0.0,  0.4,  0.4,  1.0, # The front blue one
        -1.25, -1.0,   0.0,  0.4,  0.4,  1.0,
        -0.25, -1.0,   0.0,  1.0,  0.4,  0.4,
    ]

    n = verticesColors.length / 6

    # Create a buffer object
    vertexColorBuffer = gl.createBuffer()
    if !vertexColorBuffer
        console.error 'Failed to create the buffer object'
        return -1

    # Bind the buffer object to target
    gl.bindBuffer gl.ARRAY_BUFFER, vertexColorBuffer
    # Write data into the buffer object
    gl.bufferData gl.ARRAY_BUFFER, verticesColors, gl.STATIC_DRAW

    FSIZE = verticesColors.BYTES_PER_ELEMENT

    a_Position = gl.getAttribLocation gl.program, 'a_Position'
    if a_Position < 0
        console.error 'Failed to get the storage location of a_Position'
        return -1

    gl.vertexAttribPointer a_Position, 3, gl.FLOAT, false, FSIZE * 6, 0
    gl.enableVertexAttribArray a_Position

    a_Color = gl.getAttribLocation gl.program, 'a_Color'
    if a_Color < 0
        console.log 'Failed to get the storage location of a_Color'
        return -1

    gl.vertexAttribPointer a_Color, 3, gl.FLOAT, false, FSIZE * 6, FSIZE * 3
    gl.enableVertexAttribArray a_Color

    n

ready = (gl) ->
    canvasApp = @
    vertexNum = initVertexBuffers gl
    if vertexNum < 0
        console.error 'Failed to set the positions of the vertices'

    initMatrix gl

# called every frame
render = (gl, width, height, dt) ->
    clear gl
    gl.drawArrays gl.TRIANGLES, 0, vertexNum

resize = (gl, width, height) ->
    projMatrix = mat4.create()
    # out, fovy, aspect, near, far
    mat4.perspective projMatrix, 30*Math.PI/180, width/height, 1, 100

    gl.uniformMatrix4fv u_ProjMatrix, false, projMatrix

common ready, render, vShaderSource, fShaderSource, resize