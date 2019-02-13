// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Textured With Detail"{
    // Shader的属性
    Properties {
        _Tint ("Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _DetailTex ("Detail Texture", 2D) = "gray" {}
    }

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

            // 最上面定义了属性之后 我们还需要访问属性
            float4 _Tint;
            sampler2D _MainTex, _DetailTex;
            float4 _MainTex_ST, _DetailTex_ST; //ST表示缩放和平移

            struct Interpolators {
                // 四个浮点数的集合 用来弄矩阵的 SV_POSITION是语义 SV表示系统值 POSITION表示最终顶点位置 告诉图形处理器 我们尝试输出顶点的位置
                float4 position : SV_POSITION;
                // 出于什么目的使用TEXCOORD0还待考究
                float2 uv : TEXCOORD0;
                float2 uvDetail : TEXCOORD1;
            };

            struct VertexData {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
            };

            Interpolators MyVertexProgram(VertexData v) {
                // mul 乘法指令
                // UNITY_MATRIX_MVP是UnityCG里面的UnityShaderVariables 专门用来将顶点正确的投影到显示器上去的
                // 会被Unity升级为UnityObjectToClipPos
                Interpolators i;
                i.position = UnityObjectToClipPos(v.position);
                // i.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                // 这个方法就是用来缩放和平移uv的
                i.uv = TRANSFORM_TEX(v.uv, _MainTex);
                i.uvDetail = TRANSFORM_TEX(v.uv, _DetailTex);
                return i;
            }

            // 这个主要用来输出一个RGBA颜色值 默认着色器目标 也就是帧缓冲区 包含我们正在生成的图像
            // 需要接收输入 输入就是顶点程序产生的值
            float4 MyFragmentProgram(Interpolators i) : SV_TARGET {
                float4 color = tex2D(_MainTex, i.uv) * _Tint;
                color *= tex2D(_MainTex, i.uv * 10) * 2;
                return color;
            }

            ENDCG
        }
    }   
}
