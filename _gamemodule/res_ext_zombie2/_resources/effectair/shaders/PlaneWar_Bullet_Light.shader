Shader "PlaneWar/Bullet_Light"
{
  Properties
  {
    _MainTex ("MainTex", 2D) = "white" {}
    _Line ("Line", float) = 4
    _Speed ("播放速度", float) = 150
  }
  SubShader
  {
    Tags
    { 
      "IGNOREPROJECTOR" = "true"
      "QUEUE" = "Transparent"
      "RenderType" = "Transparent"
    }
    Pass // ind: 1, name: 
    {
      Tags
      { 
        "IGNOREPROJECTOR" = "true"
        "QUEUE" = "Transparent"
        "RenderType" = "Transparent"
      }
      ZWrite Off
      Blend SrcAlpha One
      // m_ProgramMask = 6
      CGPROGRAM
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      
      
      //uniform float4 _Time;
      
      //uniform float4 unity_ObjectToWorld[4];
      
      //uniform float4 unity_MatrixVP[4];
      
      uniform int _Line;
      
      uniform float _Speed;
      
      uniform sampler2D _MainTex;
      
      
      
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
      
      float u_xlat2;
      
      int u_xlatb4;
      
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
          
          u_xlat0.x = _Time.y * _Speed;
          
          u_xlat0.x = floor(u_xlat0.x);
          
          u_xlat2 = float(_Line);
          
          u_xlat0.x = u_xlat0.x / u_xlat2;
          
          u_xlatb4 = u_xlat0.x>=(-u_xlat0.x);
          
          u_xlat0.x = frac(abs(u_xlat0.x));
          
          u_xlat0.x = (u_xlatb4) ? u_xlat0.x : (-u_xlat0.x);
          
          u_xlat0.x = u_xlat2 * u_xlat0.x;
          
          u_xlat2 = float(1.0) / u_xlat2;
          
          u_xlat0.x = u_xlat0.x * u_xlat2;
          
          out_v.texcoord.y = in_v.texcoord.y * u_xlat2 + u_xlat0.x;
          
          out_v.texcoord.x = in_v.texcoord.x;
          
          return out_v;
      
      }
      
      
      #define CODE_BLOCK_FRAGMENT
      
      
      
      
      float4 u_xlat10_0;
      
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          
          u_xlat10_0 = tex2D(_MainTex, in_f.texcoord.xy);
          
          out_f.color = u_xlat10_0;
          
          return out_f;
      
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack "Diffuse"
}
