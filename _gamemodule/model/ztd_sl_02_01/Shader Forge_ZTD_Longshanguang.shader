Shader "Shader Forge/ZTD_Longshanguang"
{
  Properties
  {
    _node_5835 ("node_5835", 2D) = "white" {}
    _node_326 ("node_326", 2D) = "white" {}
    _node_9037 ("node_9037", Color) = (0.5,0.5,0.5,1)
  }
  SubShader
  {
    Tags
    { 
      "IGNOREPROJECTOR" = "true"
      "QUEUE" = "Transparent"
      "RenderType" = "Transparent"
    }
    Pass // ind: 1, name: FORWARD
    {
      Name "FORWARD"
      Tags
      { 
        "IGNOREPROJECTOR" = "true"
        "LIGHTMODE" = "FORWARDBASE"
        "QUEUE" = "Transparent"
        "RenderType" = "Transparent"
        "SHADOWSUPPORT" = "true"
      }
      ZWrite Off
      Blend One One
      // m_ProgramMask = 6
      CGPROGRAM
      #pragma multi_compile DIRECTIONAL
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      
      
      uniform float4 unity_ObjectToWorld[4];
      
      uniform float4 unity_MatrixVP[4];
      
      uniform float4 _Time;
      
      uniform float4 _node_5835_ST;
      
      uniform float4 _node_326_ST;
      
      uniform float4 _node_9037;
      
      uniform sampler2D _node_5835;
      
      uniform sampler2D _node_326;
      
      
      
      struct appdata_t
      {
          
          float4 vertex : POSITION0;
          
          float2 texcoord : TEXCOORD0;
      
      };
      
      
      struct OUT_Data_Vert
      {
          
          float2 texcoord : TEXCOORD0;
          
          float4 vertex : SV_POSITION;
      
      };
      
      
      struct v2f
      {
          
          float2 texcoord : TEXCOORD0;
      
      };
      
      
      struct OUT_Data_Frag
      {
          
          float4 color : SV_Target0;
      
      };
      
      
      float4 u_xlat0;
      
      float4 u_xlat1;
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          
          u_xlat0 = in_v.vertex.yyyy * unity_ObjectToWorld[1];
          
          u_xlat0 = unity_ObjectToWorld[0] * in_v.vertex.xxxx + u_xlat0;
          
          u_xlat0 = unity_ObjectToWorld[2] * in_v.vertex.zzzz + u_xlat0;
          
          u_xlat0 = u_xlat0 + unity_ObjectToWorld[3];
          
          u_xlat1 = u_xlat0.yyyy * unity_MatrixVP[1];
          
          u_xlat1 = unity_MatrixVP[0] * u_xlat0.xxxx + u_xlat1;
          
          u_xlat1 = unity_MatrixVP[2] * u_xlat0.zzzz + u_xlat1;
          
          out_v.vertex = unity_MatrixVP[3] * u_xlat0.wwww + u_xlat1;
          
          out_v.texcoord.xy = in_v.texcoord.xy;
          
          return;
      
      }
      
      
      #define CODE_BLOCK_FRAGMENT
      
      
      
      
      float3 u_xlat0_d;
      
      float u_xlat10_0;
      
      float2 u_xlat1_d;
      
      float u_xlat10_6;
      
      OUT_Data_Frag frag(v2f in_f)
      {
          
          u_xlat0_d.xy = _Time.yy * float2(0.100000001, 0.0500000007) + in_f.texcoord.xy;
          
          u_xlat0_d.xy = u_xlat0_d.xy * _node_326_ST.xy + _node_326_ST.zw;
          
          u_xlat10_0 = texture2D(_node_326, u_xlat0_d.xy).w;
          
          u_xlat0_d.xyz = float3(u_xlat10_0) * _node_9037.xyz;
          
          u_xlat1_d.xy = in_f.texcoord.xy * _node_5835_ST.xy + _node_5835_ST.zw;
          
          u_xlat10_6 = texture2D(_node_5835, u_xlat1_d.xy).w;
          
          u_xlat0_d.xyz = u_xlat0_d.xyz * float3(u_xlat10_6);
          
          out_f.color.xyz = u_xlat0_d.xyz * float3(3.0, 3.0, 3.0);
          
          out_f.color.w = 1.0;
          
          return;
      
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack "Diffuse"
}
