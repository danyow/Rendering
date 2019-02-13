// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Texture Splatting"{
    // Shader的属性
    Properties {
        // _Tint ("Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Splat Map", 2D) = "white" {}
        // NoScaleOffset 名字建议 不使用缩放和平移
        [NoScaleOffset] _Texture1 ("Texure 1", 2D) = "white" {}
        [NoScaleOffset] _Texture2 ("Texure 2", 2D) = "white" {}
        [NoScaleOffset] _Texture3 ("Texure 3", 2D) = "white" {}
        [NoScaleOffset] _Texture4 ("Texure 4", 2D) = "white" {}
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
            // float4 _Tint;
            sampler2D _MainTex;
            float4 _MainTex_ST; //ST表示缩放和平移

            sampler2D _Texture1, _Texture2, _Texture3, _Texture4;

            struct Interpolators {
                // 四个浮点数的集合 用来弄矩阵的 SV_POSITION是语义 SV表示系统值 POSITION表示最终顶点位置 告诉图形处理器 我们尝试输出顶点的位置
                float4 position : SV_POSITION;
                // 出于什么目的使用TEXCOORD0还待考究
                float2 uv : TEXCOORD0;
                float2 uvSplat : TEXCOORD1;
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
                i.uvSplat = v.uv;
                return i;
            }

            // 这个主要用来输出一个RGBA颜色值 默认着色器目标 也就是帧缓冲区 包含我们正在生成的图像
            // 需要接收输入 输入就是顶点程序产生的值
            float4 MyFragmentProgram(Interpolators i) : SV_TARGET {
                float4 splat = tex2D(_MainTex, i.uvSplat);
                return
                    tex2D(_Texture1, i.uv) * splat.r + 
                    tex2D(_Texture2, i.uv) * splat.g + 
                    tex2D(_Texture3, i.uv) * splat.b + 
                    tex2D(_Texture4, i.uv) * (1 - splat.r - splat.g - splat.b);
            }

            ENDCG
        }
    }   
}
