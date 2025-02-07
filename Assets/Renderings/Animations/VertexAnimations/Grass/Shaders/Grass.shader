Shader "zer0/Animations/VertexAnimations/Grass" {

    Properties {
        _MainTex ("Main Tex", 2D) = "white" {}
        _Magnitude ("Distortion Magnitude", Float) = 1
        _Frequency ("Distortion Frequency", Float) = 1
    }

    SubShader {
        Tags { "RenderType" = "Transparent" "IgnoreProjector" = "True" "Queue" = "Transparent" "DisableBatching" = "True" }

        Pass {
            Tags { "LightMode" = "ForwardBase" }

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Magnitude;
            float _Frequency;
            float3 _Wind;

            struct a2v {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(a2v i) {
                v2f o;

                float3 displacement;
                displacement = sin(_Wind * _Time.y * _Frequency) * _Magnitude;
                displacement *= i.uv.y;     // the root don't move
                i.pos.xyz += displacement;

                // billboard
                float3 center = float3(0, 0, 0);
                float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
                fixed3 toCamera = normalize(viewer - center);
                toCamera.y = 0.0f;     // rotate around y-axis
                fixed3 upDir = float3(0, 1, 0);
                fixed3 rightDir = normalize(cross(upDir, toCamera));
                upDir = normalize(cross(toCamera, rightDir));
                float3 centerOffset = i.pos.xyz - center;
                float3 localPos = center + rightDir * centerOffset.x + upDir * centerOffset.y + toCamera * centerOffset.z; // transform to billboard space

                o.pos = UnityObjectToClipPos(localPos);
                o.uv = TRANSFORM_TEX(i.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
 				fixed4 c = tex2D (_MainTex, i.uv);
				
				return c;
            }

            ENDCG

        }

    }

    FallBack "VertexLit"
}