// Upgrade NOTE: commented out 'float3 _WorldSpaceCameraPos', a built-in variable

Shader "Shader Forge/ZTD_SL_02_01"
{
  Properties
  {
    _Diffuse ("Diffuse", 2D) = "white" {}
    _Color ("Color", Color) = (0.5,0.5,0.5,1)
    _Gloss ("Gloss", Range(0, 1)) = 0.5
    _SpecColor ("Spec Color", Color) = (1,1,1,1)
    [HideInInspector] _Cutoff ("Alpha cutoff", Range(0, 1)) = 0.5
  }
  SubShader
  {
    Tags
    { 
      "QUEUE" = "AlphaTest"
      "RenderType" = "TransparentCutout"
    }
    Pass // ind: 1, name: FORWARD
    {
      Name "FORWARD"
      Tags
      { 
        "LIGHTMODE" = "FORWARDBASE"
        "QUEUE" = "AlphaTest"
        "RenderType" = "TransparentCutout"
        "SHADOWSUPPORT" = "true"
      }
      // m_ProgramMask = 6
      CGPROGRAM
      #pragma multi_compile DIRECTIONAL
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      
      
      uniform float4 unity_ObjectToWorld[4];
      
      uniform float4 unity_WorldToObject[4];
      
      uniform float4 unity_MatrixVP[4];
      
      // uniform float3 _WorldSpaceCameraPos;
      
      uniform float4 _WorldSpaceLightPos0;
      
      uniform float4 glstate_lightmodel_ambient;
      
      uniform float4 _LightColor0;
      
      uniform float4 _SpecColor;
      
      uniform float4 _Diffuse_ST;
      
      uniform float4 _Color;
      
      uniform float _Gloss;
      
      uniform sampler2D _Diffuse;
      
      
      
      struct appdata_t
      {
          
          float4 vertex : POSITION0;
          
          float3 normal : NORMAL0;
          
          float2 texcoord : TEXCOORD0;
      
      };
      
      
      struct OUT_Data_Vert
      {
          
          float2 texcoord : TEXCOORD0;
          
          float4 texcoord1 : TEXCOORD1;
          
          float3 texcoord2 : TEXCOORD2;
          
          float4 vertex : SV_POSITION;
      
      };
      
      
      struct v2f
      {
          
          float2 texcoord : TEXCOORD0;
          
          float4 texcoord1 : TEXCOORD1;
          
          float3 texcoord2 : TEXCOORD2;
      
      };
      
      
      struct OUT_Data_Frag
      {
          
          float4 color : SV_Target0;
      
      };
      
      
      float4 u_xlat0;
      
      float4 u_xlat1;
      
      float u_xlat6;
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          
          u_xlat0 = in_v.vertex.yyyy * unity_ObjectToWorld[1];
          
          u_xlat0 = unity_ObjectToWorld[0] * in_v.vertex.xxxx + u_xlat0;
          
          u_xlat0 = unity_ObjectToWorld[2] * in_v.vertex.zzzz + u_xlat0;
          
          u_xlat1 = u_xlat0 + unity_ObjectToWorld[3];
          
          out_v.texcoord1 = unity_ObjectToWorld[3] * in_v.vertex.wwww + u_xlat0;
          
          u_xlat0 = u_xlat1.yyyy * unity_MatrixVP[1];
          
          u_xlat0 = unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat0;
          
          u_xlat0 = unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat0;
          
          out_v.vertex = unity_MatrixVP[3] * u_xlat1.wwww + u_xlat0;
          
          out_v.texcoord.xy = in_v.texcoord.xy;
          
          u_xlat0.x = dot(in_v.normal.xyz, unity_WorldToObject[0].xyz);
          
          u_xlat0.y = dot(in_v.normal.xyz, unity_WorldToObject[1].xyz);
          
          u_xlat0.z = dot(in_v.normal.xyz, unity_WorldToObject[2].xyz);
          
          u_xlat6 = dot(u_xlat0.xyz, u_xlat0.xyz);
          
          u_xlat6 = inversesqrt(u_xlat6);
          
          out_v.texcoord2.xyz = float3(u_xlat6) * u_xlat0.xyz;
          
          return;
      
      }
      
      
      #define CODE_BLOCK_FRAGMENT
      
      
      
      
      float3 u_xlat0_d;
      
      float4 u_xlat10_0;
      
      float3 u_xlat1_d;
      
      float3 u_xlat16_2;
      
      float3 u_xlat3;
      
      float3 u_xlat5;
      
      float u_xlat12;
      
      int u_xlatb12;
      
      OUT_Data_Frag frag(v2f in_f)
      {
          
          u_xlat0_d.xy = in_f.texcoord.xy * _Diffuse_ST.xy + _Diffuse_ST.zw;
          
          u_xlat10_0 = texture2D(_Diffuse, u_xlat0_d.xy);
          
          u_xlat12 = u_xlat10_0.w + -0.5;
          
          u_xlat0_d.xyz = u_xlat10_0.xyz * _Color.xyz;
          
          u_xlatb12 = u_xlat12<0.0;
          
          if(u_xlatb12)
      {
              discard;
      }
          
          u_xlat1_d.xyz = (-in_f.texcoord1.xyz) + _WorldSpaceCameraPos.xyz;
          
          u_xlat12 = dot(u_xlat1_d.xyz, u_xlat1_d.xyz);
          
          u_xlat12 = inversesqrt(u_xlat12);
          
          u_xlat16_2.x = dot(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz);
          
          u_xlat16_2.x = inversesqrt(u_xlat16_2.x);
          
          u_xlat16_2.xyz = u_xlat16_2.xxx * _WorldSpaceLightPos0.xyz;
          
          u_xlat1_d.xyz = u_xlat1_d.xyz * float3(u_xlat12) + u_xlat16_2.xyz;
          
          u_xlat12 = dot(u_xlat1_d.xyz, u_xlat1_d.xyz);
          
          u_xlat12 = inversesqrt(u_xlat12);
          
          u_xlat1_d.xyz = float3(u_xlat12) * u_xlat1_d.xyz;
          
          u_xlat12 = dot(in_f.texcoord2.xyz, in_f.texcoord2.xyz);
          
          u_xlat12 = inversesqrt(u_xlat12);
          
          u_xlat3.xyz = float3(u_xlat12) * in_f.texcoord2.xyz;
          
          u_xlat12 = dot(u_xlat3.xyz, u_xlat1_d.xyz);
          
          u_xlat1_d.x = dot(u_xlat16_2.xyz, u_xlat3.xyz);
          
          u_xlat1_d.x = max(u_xlat1_d.x, 0.0);
          
          u_xlat12 = max(u_xlat12, 0.0);
          
          u_xlat12 = log2(u_xlat12);
          
          u_xlat5.x = _Gloss * 10.0 + 1.0;
          
          u_xlat5.x = exp2(u_xlat5.x);
          
          u_xlat12 = u_xlat12 * u_xlat5.x;
          
          u_xlat12 = exp2(u_xlat12);
          
          u_xlat12 = u_xlat12 * u_xlat1_d.x;
          
          u_xlat5.xyz = float3(u_xlat12) * _SpecColor.xyz;
          
          u_xlat1_d.xyz = u_xlat0_d.xyz * u_xlat1_d.xxx + u_xlat5.xyz;
          
          u_xlat1_d.xyz = u_xlat1_d.xyz * _LightColor0.xyz;
          
          u_xlat16_2.xyz = glstate_lightmodel_ambient.xyz + glstate_lightmodel_ambient.xyz;
          
          out_f.color.xyz = u_xlat0_d.xyz * u_xlat16_2.xyz + u_xlat1_d.xyz;
          
          out_f.color.w = 1.0;
          
          return;
      
      }
      
      
      ENDCG
      
    } // end phase
    Pass // ind: 2, name: FORWARD_DELTA
    {
      Name "FORWARD_DELTA"
      Tags
      { 
        "LIGHTMODE" = "FORWARDADD"
        "QUEUE" = "AlphaTest"
        "RenderType" = "TransparentCutout"
        "SHADOWSUPPORT" = "true"
      }
      Blend One One
      // m_ProgramMask = 6
      CGPROGRAM
      #pragma multi_compile POINT
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      
      
      uniform float4 unity_ObjectToWorld[4];
      
      uniform float4 unity_WorldToObject[4];
      
      uniform float4 unity_MatrixVP[4];
      
      uniform float4 unity_WorldToLight[4];
      
      // uniform float3 _WorldSpaceCameraPos;
      
      uniform float4 _WorldSpaceLightPos0;
      
      uniform float4 _LightColor0;
      
      uniform float4 _SpecColor;
      
      uniform float4 _Diffuse_ST;
      
      uniform float4 _Color;
      
      uniform float _Gloss;
      
      uniform sampler2D _Diffuse;
      
      uniform sampler2D _LightTexture0;
      
      
      
      struct appdata_t
      {
          
          float4 vertex : POSITION0;
          
          float3 normal : NORMAL0;
          
          float2 texcoord : TEXCOORD0;
      
      };
      
      
      struct OUT_Data_Vert
      {
          
          float2 texcoord : TEXCOORD0;
          
          float4 texcoord1 : TEXCOORD1;
          
          float3 texcoord2 : TEXCOORD2;
          
          float3 texcoord3 : TEXCOORD3;
          
          float4 vertex : SV_POSITION;
      
      };
      
      
      struct v2f
      {
          
          float2 texcoord : TEXCOORD0;
          
          float4 texcoord1 : TEXCOORD1;
          
          float3 texcoord2 : TEXCOORD2;
          
          float3 texcoord3 : TEXCOORD3;
      
      };
      
      
      struct OUT_Data_Frag
      {
          
          float4 color : SV_Target0;
      
      };
      
      
      float4 u_xlat0;
      
      float4 u_xlat1;
      
      float4 u_xlat2;
      
      float u_xlat10;
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          
          u_xlat0 = in_v.vertex.yyyy * unity_ObjectToWorld[1];
          
          u_xlat0 = unity_ObjectToWorld[0] * in_v.vertex.xxxx + u_xlat0;
          
          u_xlat0 = unity_ObjectToWorld[2] * in_v.vertex.zzzz + u_xlat0;
          
          u_xlat1 = u_xlat0 + unity_ObjectToWorld[3];
          
          u_xlat0 = unity_ObjectToWorld[3] * in_v.vertex.wwww + u_xlat0;
          
          u_xlat2 = u_xlat1.yyyy * unity_MatrixVP[1];
          
          u_xlat2 = unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat2;
          
          u_xlat2 = unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat2;
          
          out_v.vertex = unity_MatrixVP[3] * u_xlat1.wwww + u_xlat2;
          
          out_v.texcoord.xy = in_v.texcoord.xy;
          
          out_v.texcoord1 = u_xlat0;
          
          u_xlat1.x = dot(in_v.normal.xyz, unity_WorldToObject[0].xyz);
          
          u_xlat1.y = dot(in_v.normal.xyz, unity_WorldToObject[1].xyz);
          
          u_xlat1.z = dot(in_v.normal.xyz, unity_WorldToObject[2].xyz);
          
          u_xlat10 = dot(u_xlat1.xyz, u_xlat1.xyz);
          
          u_xlat10 = inversesqrt(u_xlat10);
          
          out_v.texcoord2.xyz = float3(u_xlat10) * u_xlat1.xyz;
          
          u_xlat1.xyz = u_xlat0.yyy * unity_WorldToLight[1].xyz;
          
          u_xlat1.xyz = unity_WorldToLight[0].xyz * u_xlat0.xxx + u_xlat1.xyz;
          
          u_xlat0.xyz = unity_WorldToLight[2].xyz * u_xlat0.zzz + u_xlat1.xyz;
          
          out_v.texcoord3.xyz = unity_WorldToLight[3].xyz * u_xlat0.www + u_xlat0.xyz;
          
          return;
      
      }
      
      
      #define CODE_BLOCK_FRAGMENT
      
      
      
      
      float3 u_xlat0_d;
      
      float4 u_xlat10_0;
      
      float3 u_xlat1_d;
      
      float3 u_xlat2_d;
      
      float3 u_xlat3;
      
      float3 u_xlat5;
      
      float u_xlat12;
      
      int u_xlatb12;
      
      OUT_Data_Frag frag(v2f in_f)
      {
          
          u_xlat0_d.xy = in_f.texcoord.xy * _Diffuse_ST.xy + _Diffuse_ST.zw;
          
          u_xlat10_0 = texture2D(_Diffuse, u_xlat0_d.xy);
          
          u_xlat12 = u_xlat10_0.w + -0.5;
          
          u_xlat0_d.xyz = u_xlat10_0.xyz * _Color.xyz;
          
          u_xlatb12 = u_xlat12<0.0;
          
          if(u_xlatb12)
      {
              discard;
      }
          
          u_xlat1_d.xyz = _WorldSpaceLightPos0.www * (-in_f.texcoord1.xyz) + _WorldSpaceLightPos0.xyz;
          
          u_xlat12 = dot(u_xlat1_d.xyz, u_xlat1_d.xyz);
          
          u_xlat12 = inversesqrt(u_xlat12);
          
          u_xlat1_d.xyz = float3(u_xlat12) * u_xlat1_d.xyz;
          
          u_xlat2_d.xyz = (-in_f.texcoord1.xyz) + _WorldSpaceCameraPos.xyz;
          
          u_xlat12 = dot(u_xlat2_d.xyz, u_xlat2_d.xyz);
          
          u_xlat12 = inversesqrt(u_xlat12);
          
          u_xlat2_d.xyz = u_xlat2_d.xyz * float3(u_xlat12) + u_xlat1_d.xyz;
          
          u_xlat12 = dot(u_xlat2_d.xyz, u_xlat2_d.xyz);
          
          u_xlat12 = inversesqrt(u_xlat12);
          
          u_xlat2_d.xyz = float3(u_xlat12) * u_xlat2_d.xyz;
          
          u_xlat12 = dot(in_f.texcoord2.xyz, in_f.texcoord2.xyz);
          
          u_xlat12 = inversesqrt(u_xlat12);
          
          u_xlat3.xyz = float3(u_xlat12) * in_f.texcoord2.xyz;
          
          u_xlat12 = dot(u_xlat3.xyz, u_xlat2_d.xyz);
          
          u_xlat1_d.x = dot(u_xlat1_d.xyz, u_xlat3.xyz);
          
          u_xlat1_d.x = max(u_xlat1_d.x, 0.0);
          
          u_xlat12 = max(u_xlat12, 0.0);
          
          u_xlat12 = log2(u_xlat12);
          
          u_xlat5.x = _Gloss * 10.0 + 1.0;
          
          u_xlat5.x = exp2(u_xlat5.x);
          
          u_xlat12 = u_xlat12 * u_xlat5.x;
          
          u_xlat12 = exp2(u_xlat12);
          
          u_xlat12 = u_xlat12 * u_xlat1_d.x;
          
          u_xlat5.xyz = float3(u_xlat12) * _SpecColor.xyz;
          
          u_xlat0_d.xyz = u_xlat0_d.xyz * u_xlat1_d.xxx + u_xlat5.xyz;
          
          u_xlat0_d.xyz = u_xlat0_d.xyz * _LightColor0.xyz;
          
          u_xlat12 = dot(in_f.texcoord3.xyz, in_f.texcoord3.xyz);
          
          u_xlat12 = texture2D(_LightTexture0, float2(u_xlat12)).x;
          
          out_f.color.xyz = float3(u_xlat12) * u_xlat0_d.xyz;
          
          out_f.color.w = 0.0;
          
          return;
      
      }
      
      
      ENDCG
      
    } // end phase
    Pass // ind: 3, name: ShadowCaster
    {
      Name "ShadowCaster"
      Tags
      { 
        "LIGHTMODE" = "SHADOWCASTER"
        "QUEUE" = "AlphaTest"
        "RenderType" = "TransparentCutout"
        "SHADOWSUPPORT" = "true"
      }
      Offset 1, 1
      // m_ProgramMask = 6
      CGPROGRAM
      #pragma multi_compile SHADOWS_DEPTH
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      
      
      uniform float4 unity_LightShadowBias;
      
      uniform float4 unity_ObjectToWorld[4];
      
      uniform float4 unity_MatrixVP[4];
      
      uniform float4 _Diffuse_ST;
      
      uniform sampler2D _Diffuse;
      
      
      
      struct appdata_t
      {
          
          float4 vertex : POSITION0;
          
          float2 texcoord : TEXCOORD0;
      
      };
      
      
      struct OUT_Data_Vert
      {
          
          float2 texcoord1 : TEXCOORD1;
          
          float4 vertex : SV_POSITION;
      
      };
      
      
      struct v2f
      {
          
          float2 texcoord1 : TEXCOORD1;
      
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
          
          out_v.texcoord1.xy = in_v.texcoord.xy;
          
          return;
      
      }
      
      
      #define CODE_BLOCK_FRAGMENT
      
      
      
      
      float2 u_xlat0_d;
      
      float u_xlat10_0;
      
      int u_xlatb0;
      
      OUT_Data_Frag frag(v2f in_f)
      {
          
          u_xlat0_d.xy = in_f.texcoord1.xy * _Diffuse_ST.xy + _Diffuse_ST.zw;
          
          u_xlat10_0 = texture2D(_Diffuse, u_xlat0_d.xy).w;
          
          u_xlat0_d.x = u_xlat10_0 + -0.5;
          
          u_xlatb0 = u_xlat0_d.x<0.0;
          
          if(u_xlatb0)
      {
              discard;
      }
          
          out_f.color = float4(0.0, 0.0, 0.0, 0.0);
          
          return;
      
      }
      
      
      ENDCG
      
    } // end phase
  }
  FallBack "Diffuse"
}
