Shader "PostProcess/DualKawase"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize ("Blur Size" ,Float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        CGINCLUDE
        #include "UnityCG.cginc"

        struct v2f_downSample
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            float4 uv01: TEXCOORD2;
            float4 uv23: TEXCOORD3;
        };

        struct v2f_upSample
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
		    float4 uv01: TEXCOORD1;
		    float4 uv23: TEXCOORD2;
		    float4 uv45: TEXCOORD3;
		    float4 uv67: TEXCOORD4;
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;
        float4 _MainTex_TexelSize;
        float _BlurSize;

        v2f_downSample vert_downSample(appdata_img v)
        {
            v2f_downSample o;
            o.pos = UnityObjectToClipPos(v.vertex);

            float2 uv = TRANSFORM_TEX(v.texcoord, _MainTex);
            o.uv = uv;
            o.uv01.xy = uv + float2(0.5 + _BlurSize,0.5 + _BlurSize) * _MainTex_TexelSize.xy;
            o.uv01.zw = uv + float2(0.5 + _BlurSize,-0.5 - _BlurSize) * _MainTex_TexelSize.xy;
            o.uv23.xy = uv + float2(-0.5 - _BlurSize,0.5 + _BlurSize) * _MainTex_TexelSize.xy;
            o.uv23.zw = uv + float2(-0.5 - _BlurSize,-0.5 - _BlurSize) * _MainTex_TexelSize.xy;
            return o;
        }

        v2f_upSample vert_upSample(appdata_img v){
            v2f_upSample o;
            o.pos = UnityObjectToClipPos(v.vertex);             

            float2 uv = TRANSFORM_TEX(v.texcoord, _MainTex);
            o.uv = uv;                
            o.uv01.xy = uv + float2(0.5 + _BlurSize,0.5 + _BlurSize) * _MainTex_TexelSize.xy;
            o.uv01.zw = uv + float2(0.5 + _BlurSize,-0.5 - _BlurSize) * _MainTex_TexelSize.xy;
            o.uv23.xy = uv + float2(-0.5 - _BlurSize,0.5 + _BlurSize) * _MainTex_TexelSize.xy;
            o.uv23.zw = uv + float2(-0.5 - _BlurSize,-0.5 - _BlurSize) * _MainTex_TexelSize.xy;

            o.uv45.xy = uv + float2(1.0 + _BlurSize,         0.0) * _MainTex_TexelSize.xy;
            o.uv45.zw = uv + float2(-1.0 - _BlurSize,       0.0) * _MainTex_TexelSize.xy;
            o.uv67.xy = uv + float2(0.0         ,1.0 + _BlurSize) * _MainTex_TexelSize.xy;
            o.uv67.zw = uv + float2(0.0        ,-1.0 - _BlurSize) * _MainTex_TexelSize.xy;
            return o;
        }

        fixed4 frag_downSample (v2f_downSample i) : SV_Target
        {
		    half4 sum = tex2D(_MainTex, i.uv) * 4;
		    sum += tex2D(_MainTex, i.uv01.xy);
		    sum += tex2D(_MainTex, i.uv01.zw);
		    sum += tex2D(_MainTex, i.uv23.xy);
		    sum += tex2D(_MainTex, i.uv23.zw);
		
		    return sum * 0.125;
        }

        fixed4 frag_upSample(v2f_upSample i) : SV_Target{
		    half4 sum = 0;
		    sum += tex2D(_MainTex, i.uv01.xy);
		    sum += tex2D(_MainTex, i.uv01.zw) * 2;
		    sum += tex2D(_MainTex, i.uv23.xy);
		    sum += tex2D(_MainTex, i.uv23.zw) * 2;
		    sum += tex2D(_MainTex, i.uv45.xy);
		    sum += tex2D(_MainTex, i.uv45.zw) * 2;
		    sum += tex2D(_MainTex, i.uv67.xy);
		    sum += tex2D(_MainTex, i.uv67.zw) * 2;
		
		    return sum * 0.0833;                
        }
        ENDCG

        Cull Off ZWrite Off ZTest Always

        pass{
            Name "DownSample"

            CGPROGRAM
            #pragma vertex vert_downSample
            #pragma fragment frag_downSample
            ENDCG
        }

        pass{
            Name "UpSample"

            CGPROGRAM
            #pragma vertex vert_upSample
            #pragma fragment frag_upSample
            ENDCG
        }

    }
}
