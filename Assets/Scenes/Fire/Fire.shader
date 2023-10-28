Shader "Fire"
{
    Properties
    {
        _Noise ("Noise", 2D) = "white" {}
        _Gradient ("Gradient",2D) = "white" {}
        _FireShape ("Fire Shape",2D) = "white" {}
        _CullOffset ("Cull Offset",Range(0,1)) = 0.5
        _FireSpeed ("Fire Speed",Float) = 0.3
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _Noise;
            sampler2D _Gradient;
            sampler2D _FireShape;
            float _CullOffset;
            float _FireSpeed;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half2 uv = i.uv - half2(0,_FireSpeed * _Time.y);

                fixed noise = tex2D(_Noise, uv).r;
                fixed gradient = tex2D(_Gradient,uv).r;
                fixed fireshape = tex2D(_FireShape,i.uv).r;

                fixed dissolveShape = fireshape - _CullOffset;
                fixed dissolveXY = 1.0 - noise - dissolveShape;
                fixed dissolveY = dissolveShape - i.uv.y;

               clip(dissolveY - dissolveXY);

                fixed3 fireColor = noise.xxx;

                return fixed4(fireColor,1.0);
            }
            ENDCG
        }
    }
}
