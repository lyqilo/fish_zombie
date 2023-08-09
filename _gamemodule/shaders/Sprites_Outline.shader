Shader "Sprites/Outline"
{
  Properties
  {
    _MainTex ("Main Texture", 2D) = "white" {}
    _AlphaThreshold ("Outline Alpha Threshold", float) = 1
    _OutlineColor ("Outline Color", Color) = (0,0,0,1)
    _Width ("Outline Width", float) = 2
  }
  SubShader
  {
    Tags
    { 
      "QUEUE" = "Transparent"
      "RenderType" = "Transparent"
    }
    Pass // ind: 1, name: 
    {
      Tags
      { 
        "QUEUE" = "Transparent"
        "RenderType" = "Transparent"
      }
      ZTest Always
      ZWrite Off
      Cull Off
      Blend SrcAlpha OneMinusSrcAlpha
      // m_ProgramMask = 6
      CGPROGRAM
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      
      
      //uniform float4 unity_ObjectToWorld[4];
      
      //uniform float4 unity_MatrixVP[4];
      
      uniform float4 _MainTex_TexelSize;
      
      uniform float _Width;
      
      uniform float _AlphaThreshold;
      
      uniform float4 _OutlineColor;
      
      uniform sampler2D _MainTex;
      
      
      
      struct appdata_t
      {
          
          float4 vertex : POSITION0;
          
          float2 texcoord : TEXCOORD0;
      
      };
      
      
      struct OUT_Data_Vert
      {
          
          float2 texcoord : TEXCOORD0;
          
          float2 texcoord1 : TEXCOORD1;
          
          float2 texcoord2 : TEXCOORD2;
          
          float2 texcoord3 : TEXCOORD3;
          
          float2 texcoord4 : TEXCOORD4;
          
          float2 texcoord5 : TEXCOORD5;
          
          float2 texcoord6 : TEXCOORD6;
          
          float2 texcoord7 : TEXCOORD7;
          
          float2 texcoord8 : TEXCOORD8;
          
          float4 vertex : SV_POSITION;
      
      };
      
      
      struct v2f
      {
          
          float2 texcoord : TEXCOORD0;
          
          float2 texcoord1 : TEXCOORD1;
          
          float2 texcoord2 : TEXCOORD2;
          
          float2 texcoord3 : TEXCOORD3;
          
          float2 texcoord4 : TEXCOORD4;
          
          float2 texcoord5 : TEXCOORD5;
          
          float2 texcoord6 : TEXCOORD6;
          
          float2 texcoord7 : TEXCOORD7;
          
          float2 texcoord8 : TEXCOORD8;
      
      };
      
      
      struct OUT_Data_Frag
      {
          
          float4 color : SV_Target0;
      
      };
      
      
      float4 u_xlat0;
      
      float4 u_xlat16_0;
      
      float4 u_xlat1;
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          
          u_xlat0 = in_v.vertex.yyyy * unity_ObjectToWorld[1];
          
          u_xlat0 = unity_ObjectToWorld[0] * in_v.vertex.xxxx + u_xlat0;
          
          u_xlat0 = unity_ObjectToWorld[2] * in_v.vertex.zzzz + u_xlat0;
          
          u_xlat0 = u_xlat0 + unity_ObjectToWorld[3];
          
          u_xlat1 = u_xlat0.yyyy * unity_MatrixVP[1];
          
          u_xlat1 = unity_MatrixVP[0] * u_xlat0.xxxx + u_xlat1;
          
          u_xlat1 = unity_MatrixVP[2] * u_xlat0.zzzz + u_xlat1;
          
          out_v.vertex = unity_MatrixVP[3] * u_xlat0.wwww + u_xlat1;
          
          out_v.texcoord.xy = (-_MainTex_TexelSize.xy) * float2(_Width,0) + in_v.texcoord.xy;
          
          u_xlat16_0 = _MainTex_TexelSize.xyxy * float4(0.0, -1.0, 1.0, -1.0);
          
          out_v.texcoord1.xy = u_xlat16_0.xy * float2(_Width,0) + in_v.texcoord.xy;
          
          out_v.texcoord2.xy = u_xlat16_0.zw * float2(_Width,0) + in_v.texcoord.xy;
          
          u_xlat16_0 = _MainTex_TexelSize.xyxy * float4(-1.0, 0.0, 1.0, 0.0);
          
          out_v.texcoord3.xy = u_xlat16_0.xy * float2(_Width,0) + in_v.texcoord.xy;
          
          out_v.texcoord5.xy = u_xlat16_0.zw * float2(_Width,0) + in_v.texcoord.xy;
          
          out_v.texcoord4.xy = in_v.texcoord.xy;
          
          u_xlat16_0 = _MainTex_TexelSize.xyxy * float4(-1.0, 1.0, 0.0, 1.0);
          
          out_v.texcoord6.xy = u_xlat16_0.xy * float2(_Width,0) + in_v.texcoord.xy;
          
          out_v.texcoord7.xy = u_xlat16_0.zw * float2(_Width,0) + in_v.texcoord.xy;
          
          out_v.texcoord8.xy = _MainTex_TexelSize.xy * float2(_Width,0) + in_v.texcoord.xy;
          
          return out_v;
      
      }
      
      
      #define CODE_BLOCK_FRAGMENT
      
      
      
      
      float4 u_xlat0_d;
      
      float u_xlat16_0_d;
      
      float3 u_xlat1_d;
      
      float4 u_xlat10_1;
      
      int u_xlati1;
      
      int u_xlatb1;
      
      float u_xlat10_3;
      
      int u_xlatb3;
      
      float u_xlat7;
      
      int u_xlatb7;
      
      float4 phase0_Input0_1[9];
      
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          
          phase0_Input0_1[0].xy = in_f.texcoord;
          
          phase0_Input0_1[1].xy = in_f.texcoord1;
          
          phase0_Input0_1[2].xy = in_f.texcoord2;
          
          phase0_Input0_1[3].xy = in_f.texcoord3;
          
          phase0_Input0_1[4].xy = in_f.texcoord4;
          
          phase0_Input0_1[5].xy = in_f.texcoord5;
          
          phase0_Input0_1[6].xy = in_f.texcoord6;
          
          phase0_Input0_1[7].xy = in_f.texcoord7;
          
          phase0_Input0_1[8].xy = in_f.texcoord8;
          
          u_xlat16_0_d = 0.0;
          
          for(int u_xlati_loop_1 = 0 ; u_xlati_loop_1<9 ; u_xlati_loop_1++)
      
          
              {
              
              u_xlat10_3 = tex2D(_MainTex, phase0_Input0_1[u_xlati_loop_1].xy).w;
              
              u_xlat16_0_d = u_xlat16_0_d + u_xlat10_3;
      
      }
          
          u_xlatb1 = _AlphaThreshold<u_xlat16_0_d;
          
          u_xlat0_d.w = u_xlatb1 ? 1.0 : float(0.0);
          
          u_xlat10_1 = tex2D(_MainTex, phase0_Input0_1[4].xy);
          
          u_xlatb7 = 0.5<u_xlat10_1.w;
          
          u_xlat7 = u_xlatb7 ? 1.0 : float(0.0);
          
          u_xlat1_d.xyz = u_xlat10_1.xyz + (-_OutlineColor.xyz);
          
          u_xlat0_d.xyz = float3(u_xlat7,0,0) * u_xlat1_d.xyz + _OutlineColor.xyz;
          
          out_f.color = u_xlat0_d;
          
          return out_f;
      
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
