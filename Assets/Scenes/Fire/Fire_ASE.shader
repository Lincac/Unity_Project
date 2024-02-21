// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Fire_ASE"
{
	Properties
	{
		_Noise("Noise", 2D) = "white" {}
		_FireSpeed("FireSpeed", Vector) = (0,0,0,0)
		_Gradient("Gradient", 2D) = "white" {}
		_Color0("Color 0", Color) = (0.7495929,0.2901961,0.08235294,0)
		_SoftEdge("SoftEdge", Range( 0 , 1)) = 0.2
		_FireTop("FireTop", Float) = 2
		_ColorIntensity("ColorIntensity", Float) = 2
		_FireShape("FireShape", 2D) = "white" {}
		_FireOffsetInten("FireOffsetInten", Float) = 0.3
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

		uniform float4 _Color0;
		uniform float _ColorIntensity;
		uniform sampler2D _Noise;
		SamplerState sampler_Noise;
		uniform float2 _FireSpeed;
		uniform float4 _Noise_ST;
		uniform sampler2D _Gradient;
		SamplerState sampler_Gradient;
		uniform float4 _Gradient_ST;
		uniform float _FireTop;
		uniform float _SoftEdge;
		uniform sampler2D _FireShape;
		SamplerState sampler_FireShape;
		uniform float4 _FireShape_ST;
		uniform float _FireOffsetInten;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 break56 = ( _Color0 * _ColorIntensity );
			float2 uv_Noise = i.uv_texcoord * _Noise_ST.xy + _Noise_ST.zw;
			float2 panner23 = ( 1.0 * _Time.y * _FireSpeed + uv_Noise);
			float Noise38 = tex2D( _Noise, panner23 ).r;
			float2 uv_Gradient = i.uv_texcoord * _Gradient_ST.xy + _Gradient_ST.zw;
			float Top53 = ( ( 1.0 - tex2D( _Gradient, uv_Gradient ).r ) * _FireTop );
			float4 appendResult55 = (float4(break56.r , ( break56.g + ( Noise38 * Top53 ) ) , break56.b , 0.0));
			float4 FireColor75 = appendResult55;
			o.Emission = FireColor75.xyz;
			float Gradient37 = tex2D( _Gradient, uv_Gradient ).r;
			float smoothstepResult31 = smoothstep( ( Noise38 - _SoftEdge ) , Noise38 , Gradient37);
			float2 uv_FireShape = i.uv_texcoord * _FireShape_ST.xy + _FireShape_ST.zw;
			float4 tex2DNode62 = tex2D( _FireShape, ( uv_FireShape + ( (Noise38*2.0 + -1.0) * _FireOffsetInten * Top53 ) ) );
			float FireShape65 = ( tex2DNode62.r * tex2DNode62.r );
			float Opacity77 = ( smoothstepResult31 * FireShape65 );
			o.Alpha = Opacity77;
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
566.4;80.8;691.8;693.8;-332.8833;1232.349;1.219065;False;False
Node;AmplifyShaderEditor.CommentaryNode;40;-1435.983,-1828.619;Inherit;False;1692.659;1246.081;Const Parameter;23;64;62;65;37;38;53;49;6;50;48;23;26;22;28;30;29;73;84;88;89;90;92;94;;0.2729848,0.764151,0.2335707,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;29;-1372.474,-1757.789;Inherit;False;0;30;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;30;-1130.748,-1778.619;Inherit;True;Property;_Gradient;Gradient;2;0;Create;True;0;0;False;0;False;-1;013d92b8a830ded4a946e7f22b9f4539;013d92b8a830ded4a946e7f22b9f4539;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;22;-1352.002,-1431.302;Inherit;False;0;6;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;26;-1337.955,-1265.224;Inherit;False;Property;_FireSpeed;FireSpeed;1;0;Create;True;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RelayNode;28;-809.6437,-1767.404;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;23;-1067.169,-1346.604;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;6;-847.1748,-1377.533;Inherit;True;Property;_Noise;Noise;0;0;Create;True;0;0;False;0;False;-1;4c164acd821a46247b561b14aa7dc127;4c164acd821a46247b561b14aa7dc127;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;48;-573.0547,-1688.929;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-570.0207,-1591.261;Inherit;False;Property;_FireTop;FireTop;5;0;Create;True;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;-434.5937,-1356.772;Float;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-358.9197,-1658.628;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;84;-1363.046,-943.4003;Inherit;False;38;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;-172.8705,-1643.503;Inherit;False;Top;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;94;-1149.063,-901.5341;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-1369.527,-701.8335;Inherit;False;53;Top;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;90;-1375.047,-817.6222;Inherit;False;Property;_FireOffsetInten;FireOffsetInten;8;0;Create;True;0;0;False;0;False;0.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-910.5831,-831.7153;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;64;-1370.341,-1110.577;Inherit;False;0;62;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;74;329.8135,-1820.27;Inherit;False;1391.066;594.2702;Calculate Color;10;55;58;56;60;59;52;61;27;51;75;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;-734.1958,-1076.711;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;51;388.2766,-1576.155;Inherit;False;Property;_ColorIntensity;ColorIntensity;6;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;76;336.6006,-1162.726;Inherit;False;1290.636;564.5416;Calculate Opacity;9;77;67;66;31;44;43;45;41;42;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;27;379.8135,-1770.27;Inherit;False;Property;_Color0;Color 0;3;0;Create;True;0;0;False;0;False;0.7495929,0.2901961,0.08235294,0;0.7495929,0.6475257,0.1371896,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;62;-498.0312,-1109.227;Inherit;True;Property;_FireShape;FireShape;7;0;Create;True;0;0;False;0;False;-1;f0731b1cd18d6cf4a9d2f37ed2d202fa;f0731b1cd18d6cf4a9d2f37ed2d202fa;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;44;387.9779,-841.9233;Inherit;False;Property;_SoftEdge;SoftEdge;4;0;Create;True;0;0;False;0;False;0.2;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-148.048,-1086.102;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-572.2521,-1780.723;Float;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;688.3901,-1691.159;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;59;712.2328,-1435.046;Inherit;False;53;Top;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;400.5482,-948.189;Inherit;False;38;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;710.6152,-1523.99;Inherit;False;38;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;43;677.412,-932.8991;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;18.39534,-1102.047;Inherit;True;FireShape;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;400.8457,-1112.726;Inherit;False;37;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;961.6577,-1488.312;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;56;885.7064,-1706.27;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;45;395.4066,-722.1603;Inherit;False;38;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;929.3239,-708.0878;Inherit;False;65;FireShape;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;31;925.8023,-962.445;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;58;1127.849,-1530.984;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;55;1334.968,-1696.201;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;1226.619,-860.0817;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;1368.259,-846.5389;Float;False;Opacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;1516.486,-1671.435;Float;False;FireColor;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;2050.605,-1332.012;Inherit;False;75;FireColor;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;79;2051.687,-1179.261;Inherit;False;77;Opacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2263.5,-1375.937;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Fire_ASE;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;30;1;29;0
WireConnection;28;0;30;1
WireConnection;23;0;22;0
WireConnection;23;2;26;0
WireConnection;6;1;23;0
WireConnection;48;0;28;0
WireConnection;38;0;6;1
WireConnection;49;0;48;0
WireConnection;49;1;50;0
WireConnection;53;0;49;0
WireConnection;94;0;84;0
WireConnection;89;0;94;0
WireConnection;89;1;90;0
WireConnection;89;2;92;0
WireConnection;88;0;64;0
WireConnection;88;1;89;0
WireConnection;62;1;88;0
WireConnection;73;0;62;1
WireConnection;73;1;62;1
WireConnection;37;0;28;0
WireConnection;52;0;27;0
WireConnection;52;1;51;0
WireConnection;43;0;42;0
WireConnection;43;1;44;0
WireConnection;65;0;73;0
WireConnection;60;0;61;0
WireConnection;60;1;59;0
WireConnection;56;0;52;0
WireConnection;31;0;41;0
WireConnection;31;1;43;0
WireConnection;31;2;45;0
WireConnection;58;0;56;1
WireConnection;58;1;60;0
WireConnection;55;0;56;0
WireConnection;55;1;58;0
WireConnection;55;2;56;2
WireConnection;67;0;31;0
WireConnection;67;1;66;0
WireConnection;77;0;67;0
WireConnection;75;0;55;0
WireConnection;0;2;78;0
WireConnection;0;9;79;0
ASEEND*/
//CHKSM=9538334F3230E32D117883D57C16B2D5831AAA37