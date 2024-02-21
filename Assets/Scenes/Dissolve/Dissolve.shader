// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dissolve"
{
	Properties
	{
		_Flag("Flag", 2D) = "white" {}
		_DissRange("DissRange", Range( 0 , 1)) = 0.1640081
		_DissColorIntensity("DissColorIntensity", Float) = 0
		_Spread("Spread", Range( 0 , 1)) = 1
		_DissSoftEdge("DissSoftEdge", Range( 0 , 0.5)) = 0
		_Noise("Noise", 2D) = "white" {}
		_Vector0("Vector 0", Vector) = (1,1,0,0)
		_Ramp("Ramp", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _Ramp;
		uniform float _Spread;
		uniform sampler2D _Noise;
		SamplerState sampler_Noise;
		uniform float2 _Vector0;
		uniform float4 _Noise_ST;
		uniform float _DissSoftEdge;
		uniform float _DissRange;
		uniform sampler2D _Flag;
		uniform float4 _Flag_ST;
		uniform float _DissColorIntensity;
		SamplerState sampler_Flag;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float mulTime131 = _Time.y * 0.3;
			float Gradient124 = ( ( i.uv_texcoord.y - (-_Spread + (frac( mulTime131 ) - 0.0) * (1.0 - -_Spread) / (1.0 - 0.0)) ) / _Spread );
			float2 uv_Noise = i.uv_texcoord * _Noise_ST.xy + _Noise_ST.zw;
			float2 panner145 = ( 0.1 * _Time.y * _Vector0 + uv_Noise);
			float Noise147 = tex2D( _Noise, panner145 ).r;
			float DissSoftEdge_Min140 = _DissSoftEdge;
			float clampResult111 = clamp( ( distance( ( Gradient124 - Noise147 ) , DissSoftEdge_Min140 ) / _DissRange ) , 0.0 , 1.0 );
			float2 appendResult154 = (float2(clampResult111 , 0.5));
			float4 RampColor156 = tex2D( _Ramp, appendResult154 );
			float2 uv_Flag = i.uv_texcoord * _Flag_ST.xy + _Flag_ST.zw;
			float4 tex2DNode100 = tex2D( _Flag, uv_Flag );
			float DissRange114 = clampResult111;
			float4 lerpResult117 = lerp( ( RampColor156 * tex2DNode100 * _DissColorIntensity ) , tex2DNode100 , DissRange114);
			o.Emission = lerpResult117.rgb;
			float smoothstepResult107 = smoothstep( DissSoftEdge_Min140 , 0.5 , ( Gradient124 - Noise147 ));
			o.Alpha = ( tex2DNode100.a * smoothstepResult107 );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
0;73.6;1098.2;701.8;3196.354;1083.449;1.897928;True;False
Node;AmplifyShaderEditor.CommentaryNode;122;-4201.897,-644.5647;Inherit;False;1444.91;618.5667;Diss_Gradient;10;124;106;104;103;132;131;134;136;137;142;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;131;-4090.907,-264.0644;Inherit;False;1;0;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-4100.866,-136.7894;Inherit;False;Property;_Spread;Spread;4;0;Create;True;0;0;False;0;False;1;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;132;-3898.225,-269.7538;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;136;-3716.874,-242.8114;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;150;-4192.385,-1055.098;Inherit;False;1209.322;358.5482;Diss_Noise;5;144;145;143;147;146;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;142;-4067.887,-553.0619;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;144;-4142.384,-994.4905;Inherit;False;0;143;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;146;-4127.046,-858.7503;Float;False;Property;_Vector0;Vector 0;7;0;Create;True;0;0;False;0;False;1,1;0,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TFHCRemapNode;104;-3570.154,-449.9785;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;145;-3817.565,-981.3554;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;106;-3186.389,-543.7072;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;143;-3548.382,-1005.099;Inherit;True;Property;_Noise;Noise;6;0;Create;True;0;0;False;0;False;-1;None;4c164acd821a46247b561b14aa7dc127;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;137;-3123.466,-255.6601;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;124;-2941.746,-474.5569;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;147;-3207.866,-973.555;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;126;-4210.056,438.1295;Inherit;False;2134.61;569.4941;Diss_Edge;13;155;114;154;111;109;112;108;152;140;139;127;151;156;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;151;-4125.256,584.2246;Inherit;False;147;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;127;-4128.194,498.2611;Inherit;False;124;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;139;-4175.054,665.3043;Inherit;False;Property;_DissSoftEdge;DissSoftEdge;5;0;Create;True;0;0;False;0;False;0;0.2711;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;152;-3781.708,510.1587;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;140;-3860.919,664.1743;Inherit;False;DissSoftEdge_Min;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-3906.133,804.004;Inherit;False;Property;_DissRange;DissRange;2;0;Create;True;0;0;False;0;False;0.1640081;0.333;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;108;-3540.386,525.6754;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;109;-3282.585,676.0468;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;111;-3131.268,681.8242;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;154;-2884.712,705.3287;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;155;-2719.67,700.6968;Inherit;True;Property;_Ramp;Ramp;8;0;Create;True;0;0;False;0;False;-1;None;3260e869374db974ab9dacefd3c967e0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;128;-2623.844,-191.5422;Inherit;False;124;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;149;-2641.512,-53.05526;Inherit;False;147;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;156;-2388.736,707.9554;Inherit;False;RampColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;114;-2833.263,523.8207;Inherit;False;DissRange;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;148;-2399.183,-102.4218;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;100;-2297.873,-354.9259;Inherit;True;Property;_Flag;Flag;0;0;Create;True;0;0;False;0;False;-1;c4396edbc9c696247a1340fa117bbd50;c4396edbc9c696247a1340fa117bbd50;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;141;-2459.417,140.4678;Inherit;False;140;DissSoftEdge_Min;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;119;-2292.496,-515.1606;Inherit;False;Property;_DissColorIntensity;DissColorIntensity;3;0;Create;True;0;0;False;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;157;-2306.396,-642.2854;Inherit;False;156;RampColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;-1808.647,-354.7906;Inherit;False;114;DissRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;107;-2159.362,-4.61694;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;-1959.423,-604.2553;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;117;-1618.022,-548.6268;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-4120.622,-375.1376;Inherit;False;Property;_DissAmount;DissAmount;1;0;Create;True;0;0;False;0;False;0.6596516;0.344;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-1846.471,-17.69503;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-1476.438,-240.7422;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Dissolve;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;132;0;131;0
WireConnection;136;0;134;0
WireConnection;104;0;132;0
WireConnection;104;3;136;0
WireConnection;145;0;144;0
WireConnection;145;2;146;0
WireConnection;106;0;142;2
WireConnection;106;1;104;0
WireConnection;143;1;145;0
WireConnection;137;0;106;0
WireConnection;137;1;134;0
WireConnection;124;0;137;0
WireConnection;147;0;143;1
WireConnection;152;0;127;0
WireConnection;152;1;151;0
WireConnection;140;0;139;0
WireConnection;108;0;152;0
WireConnection;108;1;140;0
WireConnection;109;0;108;0
WireConnection;109;1;112;0
WireConnection;111;0;109;0
WireConnection;154;0;111;0
WireConnection;155;1;154;0
WireConnection;156;0;155;0
WireConnection;114;0;111;0
WireConnection;148;0;128;0
WireConnection;148;1;149;0
WireConnection;107;0;148;0
WireConnection;107;1;141;0
WireConnection;118;0;157;0
WireConnection;118;1;100;0
WireConnection;118;2;119;0
WireConnection;117;0;118;0
WireConnection;117;1;100;0
WireConnection;117;2;120;0
WireConnection;102;0;100;4
WireConnection;102;1;107;0
WireConnection;0;2;117;0
WireConnection;0;9;102;0
ASEEND*/
//CHKSM=9F17D822FEF8030C2E01AB6306A4B4EEFDE646BD