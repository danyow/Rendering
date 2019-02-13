// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/My First Lighting Shader"{
    // Shader的属性
    Properties {
        _Tint ("Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo", 2D) = "white" {}
        // 镜面反射率
        // _SpecularTint("Specular", Color) = (0.5, 0.5, 0.5)

        // 金属
        // Gamma 需要伽马校正
        [Gamma] _Metallic("Metallic", Range(0, 1)) = 0
        // 平滑度
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
    }

    // 子着色器
    SubShader {
        // 通道
        Pass {
            Tags {
                "LightMode" = "ForwardBase"
            }

            // 调用CG程序
            CGPROGRAM

            // 确保着色器级别高于3.0
            #pragma target 3.0
            
            // 使用我的顶点程序
            #pragma vertex MyVertexProgram
            // 使用的片段处理程序
            #pragma fragment MyFragmentProgram

            // 导入代码片段
            // #include "UnityCG.cginc"
            // 光照相关的功能
            // #include "UnityStandardBRDF.cginc"
            // 负责能量守恒
            // #include "UnityStandardUtils.cginc"
            // 避免重定义错误
            // #if !defined(MY_LIGHTING_INCLUDED)
            // #define MY_LIGHTING_INCLUDED
            // // PBS 物理规则渲染
            // #include "UnityPBSLighting.cginc"
            #include "My Lighting.cginc"
            // #endif

            ENDCG
        }
        Pass {
            Tags {
                "LightMode" = "ForwardAdd"
            }

            // 确保混合模式为添加模式 不然的话第一个光源会被覆盖
            Blend One One
            // 会重新计算深度缓冲区
            ZWrite Off

            CGPROGRAM

            #pragma target 3.0

            // #pragma multi_compile DIRECTIONAL DIRECTIONAL_COOKIE POINT POINT_COOKIE SPOT
            #pragma multi_compile_fwdadd

            #pragma vertex MyVertexProgram
            #pragma fragment MyFragmentProgram

            // #define POINT

            #include "My Lighting.cginc"

            ENDCG
        }
    }   
}
