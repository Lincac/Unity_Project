Shader "PostProcess/Bokeh"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Iteration ("Iteration",int) = 0
        _Size ("Size",float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
		Cull Off ZWrite Off ZTest Always
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
             float4 _MainTex_TexelSize;
             int _Iteration;
             float _Size;

            v2f vert (appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float c = cos(2.39996323f);
                float s = sin(2.39996323f);
		        float2x2 rot = float2x2(c, s, -s, c);
		        half4 accumulator = 0.0;
		        half4 divisor = 0.0;

		        half r = 1.0;
		        half2 angle = half2(0.0, _Size);

		        for (int j = 0; j < _Iteration; j++)
		        {
			        r += 1.0 / r;
			        angle = mul(rot, angle);
			        half4 bokeh = tex2D(_MainTex, float2(i.uv + _MainTex_TexelSize.xy * (r - 1.0) * angle));
			        accumulator += bokeh * bokeh;
			        divisor += bokeh;
		        }
		        return accumulator / divisor;
            }
            ENDCG
        }
    }
}
