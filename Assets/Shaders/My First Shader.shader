// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/My First Shader"{
    // 子着色器
    SubShader {
        // 通道
        Pass {
            // 调用CG程序
            CGPROGRAM
            
            // 使用我的顶点程序
            #pragma vertex MyVertexProgram
            // 使用的片段处理程序
            #pragma fragment MyFragmentProgram

            // 导入代码片段
            #include "UnityCG.cginc"

            // 返回四个浮点数的集合 用来弄矩阵的 SV_POSITION是语义 SV表示系统值 POSITION表示最终顶点位置 告诉图形处理器 我们尝试输出顶点的位置
            float4 MyVertexProgram(float4 position : POSITION) : SV_POSITION {
                // mul 乘法指令
                // UNITY_MATRIX_MVP是UnityCG里面的UnityShaderVariables 专门用来将顶点正确的投影到显示器上去的
                return UnityObjectToClipPos(position);
            }

            // 这个主要用来输出一个RGBA颜色值 默认着色器目标 也就是帧缓冲区 包含我们正在生成的图像
            // 需要接收输入 输入就是顶点程序产生的值
            float4 MyFragmentProgram(float4 position : SV_POSITION) : SV_TARGET {
                return float4(1, 1, 0, 1);
            }

            ENDCG
        }
    }   
}
