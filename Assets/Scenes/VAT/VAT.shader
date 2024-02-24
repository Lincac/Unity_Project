// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "VAT"
{
	Properties
	{
		_FrameCount("FrameCount", Float) = 0
		_Speed("Speed", Float) = 0.25
		_VAT_POSITION("VAT_POSITION", 2D) = "white" {}
		_VAT_NORMAL("VAT_NORMAL", 2D) = "white" {}
		_BoundMin("BoundMin", Float) = 0
		_BoundMax("BoundMax", Float) = 0
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _VAT_POSITION;
		uniform float _Speed;
		uniform float _FrameCount;
		uniform float _BoundMax;
		uniform float _BoundMin;
		uniform sampler2D _VAT_NORMAL;
		uniform sampler2D _TextureSample0;
		uniform float4 _TextureSample0_ST;
		uniform float _Smoothness;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float CurrentFrame42 = ( ( -ceil( ( frac( ( _Time.y * _Speed ) ) * _FrameCount ) ) / _FrameCount ) + ( -1.0 / _FrameCount ) );
			float2 appendResult120 = (float2(v.texcoord1.xy.x , CurrentFrame42));
			float2 UV_VAT121 = appendResult120;
			float3 break57 = ( ( (tex2Dlod( _VAT_POSITION, float4( UV_VAT121, 0, 0.0) )).rgb * ( _BoundMax - _BoundMin ) ) + _BoundMin );
			float3 appendResult58 = (float3(-break57.x , break57.z , break57.y));
			float3 Vert_Offset60 = appendResult58;
			v.vertex.xyz += Vert_Offset60;
			v.vertex.w = 1;
			float3 break63 = ((tex2Dlod( _VAT_NORMAL, float4( UV_VAT121, 0, 0.0) )).rgb*-1.0 + 1.0);
			float3 appendResult64 = (float3(-break63.x , break63.z , break63.y));
			float3 Norm_Offset66 = appendResult64;
			v.normal = Norm_Offset66;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_TextureSample0 = i.uv_texcoord * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
			o.Albedo = tex2D( _TextureSample0, uv_TextureSample0 ).rgb;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
0;73.6;634.2;701.8;3312.007;2244.835;3.370113;True;False
Node;AmplifyShaderEditor.CommentaryNode;106;-3007.672,-1441.962;Inherit;False;2200.86;1190.064;VAT;35;121;120;119;118;31;32;33;34;35;36;37;38;39;40;41;42;48;52;53;49;51;54;55;56;57;59;58;60;66;62;65;64;61;50;63;VAT;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-2918.501,-1251.641;Inherit;False;Property;_Speed;Speed;1;0;Create;True;0;0;False;0;False;0.25;0.26;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;31;-2920.574,-1337.719;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-2676.858,-1337.719;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-2596.552,-1154.789;Inherit;False;Property;_FrameCount;FrameCount;0;0;Create;True;0;0;False;0;False;0;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;34;-2491.221,-1336.682;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-2272.391,-1334.608;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CeilOpNode;37;-2094.01,-1336.682;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;38;-1934.302,-1331.497;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;39;-1745.55,-1332.534;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;40;-1748.662,-1225.715;Inherit;False;2;0;FLOAT;-1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-1572.995,-1285.415;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;-1297.687,-1274.994;Float;False;CurrentFrame;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;118;-2899.436,-929.6723;Inherit;False;42;CurrentFrame;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;119;-2911.436,-1069.672;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;120;-2559.435,-1048.994;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;121;-2386.435,-1051.672;Inherit;False;UV_VAT;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-2975.44,-678.8101;Inherit;False;121;UV_VAT;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;49;-2704.096,-823.3326;Inherit;True;Property;_VAT_POSITION;VAT_POSITION;2;0;Create;True;0;0;False;0;False;-1;394d113a022a3e8458adcde55e6e292e;394d113a022a3e8458adcde55e6e292e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;52;-2325.864,-607.5883;Inherit;False;Property;_BoundMin;BoundMin;4;0;Create;True;0;0;False;0;False;0;-2.653735;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-2325.762,-703.2883;Inherit;False;Property;_BoundMax;BoundMax;5;0;Create;True;0;0;False;0;False;0;1.072085;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;51;-2293.391,-801.1195;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;54;-2136.563,-679.6885;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;50;-2703.096,-608.3326;Inherit;True;Property;_VAT_NORMAL;VAT_NORMAL;3;0;Create;True;0;0;False;0;False;-1;None;20b36af1ed6b2ac4abcf6045838c7a8a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;61;-2328.562,-479.5702;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-1970.563,-789.6886;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;-1835.153,-663.6783;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;62;-2092.562,-481.8036;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;-1;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;57;-1635.784,-685.8671;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;63;-1882.562,-476.5702;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NegateNode;59;-1359.784,-732.8669;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;65;-1633.889,-490.9621;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;58;-1202.785,-689.8671;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;64;-1431.089,-484.3622;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;-1189.858,-493.8737;Float;False;Norm_Offset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-1016.864,-687.2137;Float;False;Vert_Offset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;67;-364.2117,-677.761;Inherit;False;60;Vert_Offset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-402.4982,-834.7095;Inherit;False;Property;_Smoothness;Smoothness;7;0;Create;True;0;0;False;0;False;0;0.26;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;122;-428.4982,-571.7095;Inherit;False;66;Norm_Offset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;123;-448.4982,-1113.709;Inherit;True;Property;_TextureSample0;Texture Sample 0;6;0;Create;True;0;0;False;0;False;-1;None;bc00f75397edb9040b0375222be82a8d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;26.07969,-964.9485;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;VAT;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;33;0;31;0
WireConnection;33;1;32;0
WireConnection;34;0;33;0
WireConnection;36;0;34;0
WireConnection;36;1;35;0
WireConnection;37;0;36;0
WireConnection;38;0;37;0
WireConnection;39;0;38;0
WireConnection;39;1;35;0
WireConnection;40;1;35;0
WireConnection;41;0;39;0
WireConnection;41;1;40;0
WireConnection;42;0;41;0
WireConnection;120;0;119;1
WireConnection;120;1;118;0
WireConnection;121;0;120;0
WireConnection;49;1;48;0
WireConnection;51;0;49;0
WireConnection;54;0;53;0
WireConnection;54;1;52;0
WireConnection;50;1;48;0
WireConnection;61;0;50;0
WireConnection;55;0;51;0
WireConnection;55;1;54;0
WireConnection;56;0;55;0
WireConnection;56;1;52;0
WireConnection;62;0;61;0
WireConnection;57;0;56;0
WireConnection;63;0;62;0
WireConnection;59;0;57;0
WireConnection;65;0;63;0
WireConnection;58;0;59;0
WireConnection;58;1;57;2
WireConnection;58;2;57;1
WireConnection;64;0;65;0
WireConnection;64;1;63;2
WireConnection;64;2;63;1
WireConnection;66;0;64;0
WireConnection;60;0;58;0
WireConnection;0;0;123;0
WireConnection;0;4;124;0
WireConnection;0;11;67;0
WireConnection;0;12;122;0
ASEEND*/
//CHKSM=DB6158DAC685ED1B68E1B7B27C033067D6BF0CB7