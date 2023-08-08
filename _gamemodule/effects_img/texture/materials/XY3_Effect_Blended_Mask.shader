Shader "XY3/Effect/Blended_Mask"
{
  Properties
  {
    [HDR] _Color ("Color", Color) = (0.5,0.5,0.5,1)
    _Texture ("Texture", 2D) = "white" {}
    _Mask ("Mask", 2D) = "white" {}
    _U ("U", float) = 0
    _V ("V", float) = 0
    _V_mask ("V_mask", float) = 0
    _U_mask ("U_mask", float) = 0
    [HideInInspector] _Cutoff ("Alpha cutoff", Range(0, 1)) = 0.5
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
      Cull Off
      Blend SrcAlpha OneMinusSrcAlpha
      // m_ProgramMask = 6
      CGPROGRAM
      #pragma multi_compile DIRECTIONAL
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      
      
      //uniform float4 unity_ObjectToWorld[4];
      
      //uniform float4 unity_MatrixVP[4];
      
      //uniform float4 _Time;
      
      uniform float4 _TimeEditor;
      
      uniform float4 _Texture_ST;
      
      uniform float4 _Mask_ST;
      
      uniform float4 _Color;
      
      uniform float _U;
      
      uniform float _V;
      
      uniform float _V_mask;
      
      uniform float _U_mask;
      
      uniform sampler2D _Texture;
      
      uniform sampler2D _Mask;
      
      
      
      struct appdata_t
      {
          
          float4 vertex : POSITION0;
          
          float2 texcoord : TEXCOORD0;
          
          float4 color : COLOR0;
      
      };
      
      
      struct OUT_Data_Vert
      {
          
          float2 texcoord : TEXCOORD0;
          
          float4 color : COLOR0;
          
          float4 vertex : SV_POSITION;
      
      };
      
      
      struct v2f
      {
          
          float2 texcoord : TEXCOORD0;
          
          float4 color : COLOR0;
      
      };
      
      
      struct OUT_Data_Frag
      {
          
          float4 color : SV_Target0;
      
      };
      
      
      float4 u_xlat0;
      
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
          
          out_v.texcoord.xy = in_v.texcoord.xy;
          
          out_v.color = in_v.color;
          
          return out_v;
      
      }
      
      
      #define CODE_BLOCK_FRAGMENT
      
      
      
      
      float4 u_xlat0_d;
      
      float4 u_xlat10_0;
      
      float4 u_xlat10_1;
      
      float2 u_xlat4;
      
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          
          u_xlat0_d.x = _Time.x + _TimeEditor.x;
          
          u_xlat0_d = u_xlat0_d.xxxx * float4(_U, _V, _U_mask, _V_mask) + in_f.texcoord.xyxy;
          
          u_xlat0_d.xy = u_xlat0_d.xy * _Texture_ST.xy + _Texture_ST.zw;
          
          u_xlat4.xy = u_xlat0_d.zw * _Mask_ST.xy + _Mask_ST.zw;
          
          u_xlat10_1 = tex2D(_Mask, u_xlat4.xy);
          
          u_xlat10_0 = tex2D(_Texture, u_xlat0_d.xy);
          
          u_xlat0_d = u_xlat10_0 * _Color;
          
          u_xlat0_d = u_xlat10_1 * u_xlat0_d;
          
          out_f.color = u_xlat0_d * in_f.color;
          
          return out_f;
      
      }
      
      
      ENDCG
      
    } // end phase
    Pass // ind: 2, name: ShadowCaster
    {
      Name "ShadowCaster"
      Tags
      { 
        "IGNOREPROJECTOR" = "true"
        "LIGHTMODE" = "SHADOWCASTER"
        "QUEUE" = "Transparent"
        "RenderType" = "Transparent"
        "SHADOWSUPPORT" = "true"
      }
      Cull Off
      Offset 1, 1
      // m_ProgramMask = 6
      CGPROGRAM
      #pragma multi_compile SHADOWS_DEPTH
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      
      
      //uniform float4 unity_LightShadowBias;
      
      //uniform float4 unity_ObjectToWorld[4];
      
      //uniform float4 unity_MatrixVP[4];
      
      
      
      struct appdata_t
      {
          
          float4 vertex : POSITION0;
      
      };
      
      
      struct OUT_Data_Vert
      {
          
          float4 vertex : SV_POSITION;
      
      };
      
      
      struct v2f
      {
          
          float4 vertex : Position;
      
      };
      
      
      struct OUT_Data_Frag
      {
          
          float4 color : SV_Target0;
      
      };
      
      
      float4 u_xlat0;
      
      float4 u_xlat1;
      
      float u_xlat4;
      
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
          
          u_xlat0 = unity_MatrixVP[3] * u_xlat0.wwww + u_xlat1;
          
          u_xlat1.x = unity_LightShadowBias.x / u_xlat0.w;
          
          u_xlat1.x = clamp(u_xlat1.x, 0.0, 1.0);
          
          u_xlat4 = u_xlat0.z + u_xlat1.x;
          
          u_xlat1.x = max((-u_xlat0.w), u_xlat4);
          
          out_v.vertex.xyw = u_xlat0.xyw;
          
          u_xlat0.x = (-u_xlat4) + u_xlat1.x;
          
          out_v.vertex.z = unity_LightShadowBias.y * u_xlat0.x + u_xlat4;
          
          return out_v;
      
      }
      
      
      #define CODE_BLOCK_FRAGMENT
      
      
      
      
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          
          out_f.color = float4(0.0, 0.0, 0.0, 0.0);
          
          return out_f;
      
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack Off
}
