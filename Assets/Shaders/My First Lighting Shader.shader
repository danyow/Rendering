// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/My First Lighting Shader"{
    // Shader的属性
    Properties {
        _Tint ("Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo", 2D) = "white" {}
        _SpecularTint("Specular", Color) = (0.5, 0.5, 0.5)
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
            
            // 使用我的顶点程序
            #pragma vertex MyVertexProgram
            // 使用的片段处理程序
            #pragma fragment MyFragmentProgram

            // 导入代码片段
            // #include "UnityCG.cginc"
            // 光照相关的功能
            #include "UnityStandardBRDF.cginc"
            // 负责能量守恒
            #include "UnityStandardUtils.cginc"

            // 最上面定义了属性之后 我们还需要访问属性
            float4 _Tint;
            sampler2D _MainTex;
            float4 _MainTex_ST; //ST表示缩放和平移
            float4 _SpecularTint;
            float _Smoothness;

            struct Interpolators {
                // 四个浮点数的集合 用来弄矩阵的 SV_POSITION是语义 SV表示系统值 POSITION表示最终顶点位置 告诉图形处理器 我们尝试输出顶点的位置
                float4 position : SV_POSITION;
                // 出于什么目的使用TEXCOORD0还待考究
                float2 uv : TEXCOORD0;
                // 法线
                float3 normal : TEXCOORD1;
                // 世界坐标 用来表示观察者方向
                float3 worldPos : TEXCOORD2;
            };

            struct VertexData {
                float4 position : POSITION;
                // 法线
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            Interpolators MyVertexProgram(VertexData v) {
                Interpolators i;
                // i.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                // 这个方法就是用来缩放和平移uv的
                i.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // mul 乘法指令
                // UNITY_MATRIX_MVP是UnityCG里面的UnityShaderVariables 专门用来将顶点正确的投影到显示器上去的
                // 会被Unity升级为UnityObjectToClipPos
                i.position = UnityObjectToClipPos(v.position);
                i.worldPos = mul(unity_ObjectToWorld, v.position);
                // unity_ObjectToWorld 将数据转换到世界坐标空间中 第四个分量必须为零
                // transpose 是转矩阵的意思
                // i.normal = mul(transpose((float3x3)unity_ObjectToWorld), v.normal);
                i.normal = UnityObjectToWorldNormal(v.normal);
                i.normal = normalize(i.normal);
                return i;
            }

            // 这个主要用来输出一个RGBA颜色值 默认着色器目标 也就是帧缓冲区 包含我们正在生成的图像
            // 需要接收输入 输入就是顶点程序产生的值
            float4 MyFragmentProgram(Interpolators i) : SV_TARGET {
                // return float4(i.localPosition + 0.5, 1) * _Tint;
                // return float4(i.uv, 1, 1);
                i.normal = normalize(i.normal);
                // return float4(i.normal * 0.5 + 0.5, 1);
                // 加入垂直光源
                // 不能有负光 所以加入max
                float3 lightDir      = _WorldSpaceLightPos0.xyz;
                // 视角方向
                float3 viewDir       = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 lightColor    = _LightColor0.rgb;
                // 反照率
                float3 albedo        = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
                // albedo *= 1 - max(_SpecularTint.r, max(_SpecularTint.g, _SpecularTint.b));
                float oneMinusReflectivity;
                albedo = EnergyConservationBetweenDiffuseAndSpecular(
                    albedo, _SpecularTint.rgb, oneMinusReflectivity
                );

                float3 diffuse       = albedo * lightColor * DotClamped(lightDir, i.normal);
                // 反射光方向
                // float3 reflectionDir = reflect(-lightDir, i.normal);
                // 入射光和视角的半矢量
                float3 halfVector = normalize(lightDir + viewDir);
                float3 specular = _SpecularTint.rgb * lightColor * pow(
                    DotClamped(halfVector, i.normal),
                    _Smoothness * 100
                );
                return float4(diffuse + specular, 1);
            }

            ENDCG
        }
    }   
}
