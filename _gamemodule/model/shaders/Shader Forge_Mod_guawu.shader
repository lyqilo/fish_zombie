// Upgrade NOTE: commented out 'float3 _WorldSpaceCameraPos', a built-in variable

Shader "Shader Forge/Mod_guawu"
{
  Properties
  {
    _Color ("Color", Color) = (0.5019608,0.5019608,0.5019608,1)
    _Metallic ("Metallic", Range(0, 1)) = 0
    _Gloss ("Gloss", Range(0, 1)) = 0
    _t1 ("t1", 2D) = "white" {}
    _t2 ("t2", 2D) = "white" {}
    _c ("c", Color) = (0.9191176,0.7289553,0.2297794,1)
    _2 ("2", Range(0, 1.5)) = 0
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
      #pragma multi_compile DIRECTIONAL DIRLIGHTMAP_OFF DYNAMICLIGHTMAP_OFF LIGHTMAP_OFF
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      
      
      //uniform float4 unity_ObjectToWorld[4];
      
      //uniform float4 unity_WorldToObject[4];
      
      //uniform float4 unity_MatrixVP[4];
      
      // uniform float3 _WorldSpaceCameraPos;
      
      //uniform float4 _WorldSpaceLightPos0;
      
      //uniform float4 unity_SpecCube0_HDR;
      
      uniform float4 _LightColor0;
      
      uniform float4 _Color;
      
      uniform float _Metallic;
      
      uniform float _Gloss;
      
      uniform float4 _t1_ST;
      
      uniform float4 _t2_ST;
      
      uniform float4 _c;
      
      uniform float _2;
      
      uniform sampler2D _t1;
      
      uniform sampler2D _t2;
      
      //uniform samplerCUBE unity_SpecCube0;
      
      
      
      struct appdata_t
      {
          
          float4 vertex : POSITION0;
          
          float3 normal : NORMAL0;
          
          float4 tangent : TANGENT0;
          
          float2 texcoord : TEXCOORD0;
          
          float2 texcoord1 : TEXCOORD1;
          
          float2 texcoord2 : TEXCOORD2;
      
      };
      
      
      struct OUT_Data_Vert
      {
          
          float2 texcoord : TEXCOORD0;
          
          float2 texcoord1 : TEXCOORD1;
          
          float2 texcoord2 : TEXCOORD2;
          
          float4 texcoord3 : TEXCOORD3;
          
          float3 texcoord4 : TEXCOORD4;
          
          float3 texcoord5 : TEXCOORD5;
          
          float3 texcoord6 : TEXCOORD6;
          
          float4 texcoord10 : TEXCOORD10;
          
          float4 vertex : SV_POSITION;
      
      };
      
      
      struct v2f
      {
          
          float2 texcoord : TEXCOORD0;
          
          float4 texcoord3 : TEXCOORD3;
          
          float3 texcoord4 : TEXCOORD4;
      
      };
      
      
      struct OUT_Data_Frag
      {
          
          float4 color : SV_Target0;
      
      };
      
      
      float4 u_xlat0;
      
      float4 u_xlat1;
      
      float3 u_xlat2;
      
      float u_xlat9;
      
      OUT_Data_Vert vert(appdata_t in_v)
      {
          OUT_Data_Vert out_v;
          
          u_xlat0 = in_v.vertex.yyyy * unity_ObjectToWorld[1];
          
          u_xlat0 = unity_ObjectToWorld[0] * in_v.vertex.xxxx + u_xlat0;
          
          u_xlat0 = unity_ObjectToWorld[2] * in_v.vertex.zzzz + u_xlat0;
          
          u_xlat1 = u_xlat0 + unity_ObjectToWorld[3];
          
          out_v.texcoord3 = unity_ObjectToWorld[3] * in_v.vertex.wwww + u_xlat0;
          
          u_xlat0 = u_xlat1.yyyy * unity_MatrixVP[1];
          
          u_xlat0 = unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat0;
          
          u_xlat0 = unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat0;
          
          out_v.vertex = unity_MatrixVP[3] * u_xlat1.wwww + u_xlat0;
          
          out_v.texcoord.xy = in_v.texcoord.xy;
          
          out_v.texcoord1.xy = in_v.texcoord1.xy;
          
          out_v.texcoord2.xy = in_v.texcoord2.xy;
          
          u_xlat0.x = dot(in_v.normal.xyz, unity_WorldToObject[0].xyz);
          
          u_xlat0.y = dot(in_v.normal.xyz, unity_WorldToObject[1].xyz);
          
          u_xlat0.z = dot(in_v.normal.xyz, unity_WorldToObject[2].xyz);
          
          u_xlat9 = dot(u_xlat0.xyz, u_xlat0.xyz);
          
          u_xlat9 = sqrt(u_xlat9);
          
          u_xlat0.xyz = float3(u_xlat9,0,0) * u_xlat0.xyz;
          
          out_v.texcoord4.xyz = u_xlat0.xyz;
          
          u_xlat1.xyz = in_v.tangent.yyy * unity_ObjectToWorld[1].xyz;
          
          u_xlat1.xyz = unity_ObjectToWorld[0].xyz * in_v.tangent.xxx + u_xlat1.xyz;
          
          u_xlat1.xyz = unity_ObjectToWorld[2].xyz * in_v.tangent.zzz + u_xlat1.xyz;
          
          u_xlat9 = dot(u_xlat1.xyz, u_xlat1.xyz);
          
          u_xlat9 = sqrt(u_xlat9);
          
          u_xlat1.xyz = float3(u_xlat9,0,0) * u_xlat1.xyz;
          
          out_v.texcoord5.xyz = u_xlat1.xyz;
          
          u_xlat2.xyz = u_xlat0.zxy * u_xlat1.yzx;
          
          u_xlat0.xyz = u_xlat0.yzx * u_xlat1.zxy + (-u_xlat2.xyz);
          
          u_xlat0.xyz = u_xlat0.xyz * in_v.tangent.www;
          
          u_xlat9 = dot(u_xlat0.xyz, u_xlat0.xyz);
          
          u_xlat9 = sqrt(u_xlat9);
          
          out_v.texcoord6.xyz = float3(u_xlat9,0,0) * u_xlat0.xyz;
          
          out_v.texcoord10 = float4(0.0, 0.0, 0.0, 0.0);
          
          return out_v;
      
      }
      
      
      #define CODE_BLOCK_FRAGMENT
      
      
      
      
      float2 u_xlat0_d;
      
      float3 u_xlat10_0;
      
      int u_xlatb0;
      
      float3 u_xlat16_1;
      
      float3 u_xlat16_2;
      
      float3 u_xlat16_3;
      
      float3 u_xlat16_4;
      
      float4 u_xlat10_4;
      
      float3 u_xlat5;
      
      float3 u_xlat6;
      
      float3 u_xlat7;
      
      float u_xlat8;
      
      float3 u_xlat16_9;
      
      float3 u_xlat16_10;
      
      float3 u_xlat16_12;
      
      float u_xlat17;
      
      float3 u_xlat19;
      
      float u_xlat28;
      
      int u_xlatb28;
      
      float u_xlat33;
      
      float u_xlat16_34;
      
      float u_xlat16_35;
      
      float u_xlat16_36;
      
      float u_xlat38;
      
      float u_xlat39;
      
      float u_xlat40;
      
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          
          u_xlat0_d.xy = in_f.texcoord.xy * _t1_ST.xy + _t1_ST.zw;
          
          u_xlat10_0.xy = tex2D(_t1, u_xlat0_d.xy).xz;
          
          u_xlat16_1.x = u_xlat10_0.y * 1.09200001;
          
          u_xlatb0 = u_xlat10_0.x>=_2;
          
          u_xlat16_12.x = (u_xlatb0) ? 1.0 : 0.0;
          
          u_xlatb0 = u_xlat16_1.x>=_2;
          
          if(!u_xlatb0)
      {
              discard;
      }
          
          u_xlat16_1.x = (u_xlatb0) ? 1.0 : 0.0;
          
          u_xlat0_d.xy = in_f.texcoord.xy * _t2_ST.xy + _t2_ST.zw;
          
          u_xlat10_0.xyz = tex2D(_t2, u_xlat0_d.xy).xyz;
          
          u_xlat16_2.xyz = u_xlat10_0.xyz + (-_c.xyz);
          
          u_xlat16_12.xyz = u_xlat16_12.xxx * u_xlat16_2.xyz + _c.xyz;
          
          u_xlat16_12.xyz = (-u_xlat10_0.xyz) + u_xlat16_12.xyz;
          
          u_xlat16_1.xyz = u_xlat16_1.xxx * u_xlat16_12.xyz + u_xlat10_0.xyz;
          
          u_xlat16_2.xyz = u_xlat16_1.xyz + float3(-0.220916301, -0.220916301, -0.220916301);
          
          u_xlat16_2.xyz = float3(_Metallic,0,0) * u_xlat16_2.xyz + float3(0.220916301, 0.220916301, 0.220916301);
          
          u_xlat16_3.xyz = (-u_xlat16_2.xyz) + float3(1.0, 1.0, 1.0);
          
          u_xlat16_34 = dot(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz);
          
          u_xlat16_34 = sqrt(u_xlat16_34);
          
          u_xlat16_4.xyz = float3(u_xlat16_34,0,0) * _WorldSpaceLightPos0.xyz;
          
          u_xlat5.xyz = (-in_f.texcoord3.xyz) + _WorldSpaceCameraPos.xyz;
          
          u_xlat33 = dot(u_xlat5.xyz, u_xlat5.xyz);
          
          u_xlat33 = sqrt(u_xlat33);
          
          u_xlat6.xyz = u_xlat5.xyz * float3(u_xlat33,0,0) + u_xlat16_4.xyz;
          
          u_xlat5.xyz = float3(u_xlat33,0,0) * u_xlat5.xyz;
          
          u_xlat33 = dot(u_xlat6.xyz, u_xlat6.xyz);
          
          u_xlat33 = sqrt(u_xlat33);
          
          u_xlat6.xyz = float3(u_xlat33,0,0) * u_xlat6.xyz;
          
          u_xlat33 = dot(u_xlat16_4.xyz, u_xlat6.xyz);
          
          u_xlat33 = clamp(u_xlat33, 0.0, 1.0);
          
          u_xlat16_34 = (-u_xlat33) + 1.0;
          
          u_xlat33 = u_xlat33 * u_xlat33;
          
          u_xlat16_35 = u_xlat16_34 * u_xlat16_34;
          
          u_xlat16_35 = u_xlat16_35 * u_xlat16_35;
          
          u_xlat16_34 = u_xlat16_34 * u_xlat16_35;
          
          u_xlat16_3.xyz = u_xlat16_3.xyz * float3(u_xlat16_34,0,0) + u_xlat16_2.xyz;
          
          u_xlat38 = dot(in_f.texcoord4.xyz, in_f.texcoord4.xyz);
          
          u_xlat38 = sqrt(u_xlat38);
          
          u_xlat7.xyz = float3(u_xlat38,0,0) * in_f.texcoord4.xyz;
          
          u_xlat38 = dot(u_xlat7.xyz, u_xlat6.xyz);
          
          u_xlat38 = clamp(u_xlat38, 0.0, 1.0);
          
          u_xlat16_34 = (-_Gloss) + 1.0;
          
          u_xlat6.x = u_xlat16_34 * u_xlat16_34;
          
          u_xlat17 = u_xlat6.x * u_xlat6.x;
          
          u_xlat28 = u_xlat38 * u_xlat17 + (-u_xlat38);
          
          u_xlat38 = u_xlat28 * u_xlat38 + 1.0;
          
          u_xlat38 = u_xlat38 * u_xlat38 + 1.00000001e-07;
          
          u_xlat17 = u_xlat17 * 0.318309873;
          
          u_xlat38 = u_xlat17 / u_xlat38;
          
          u_xlat17 = dot(u_xlat7.xyz, u_xlat16_4.xyz);
          
          u_xlat17 = max(u_xlat17, 0.0);
          
          u_xlat28 = min(u_xlat17, 1.0);
          
          u_xlat39 = (-u_xlat16_34) * u_xlat16_34 + 1.0;
          
          u_xlat40 = u_xlat28 * u_xlat39 + u_xlat6.x;
          
          u_xlat8 = dot(u_xlat7.xyz, u_xlat5.xyz);
          
          u_xlat40 = u_xlat40 * abs(u_xlat8);
          
          u_xlat39 = abs(u_xlat8) * u_xlat39 + u_xlat6.x;
          
          u_xlat6.x = u_xlat6.x * 0.280000001;
          
          u_xlat6.x = (-u_xlat6.x) * u_xlat16_34 + 1.0;
          
          u_xlat39 = u_xlat28 * u_xlat39 + u_xlat40;
          
          u_xlat39 = u_xlat39 + 9.99999975e-06;
          
          u_xlat39 = 0.5 / u_xlat39;
          
          u_xlat38 = u_xlat38 * u_xlat39;
          
          u_xlat38 = u_xlat38 * 3.14159274;
          
          u_xlat38 = max(u_xlat38, 9.99999975e-05);
          
          u_xlat38 = sqrt(u_xlat38);
          
          u_xlat38 = u_xlat28 * u_xlat38;
          
          u_xlat28 = dot(u_xlat16_2.xyz, u_xlat16_2.xyz);
          
          u_xlatb28 = u_xlat28!=0.0;
          
          u_xlat28 = u_xlatb28 ? 1.0 : float(0.0);
          
          u_xlat38 = u_xlat38 * u_xlat28;
          
          u_xlat19.xyz = float3(u_xlat38,0,0) * _LightColor0.xyz;
          
          u_xlat38 = dot((-u_xlat5.xyz), u_xlat7.xyz);
          
          u_xlat38 = u_xlat38 + u_xlat38;
          
          u_xlat5.xyz = u_xlat7.xyz * (-float3(u_xlat38,0,0)) + (-u_xlat5.xyz);
          
          u_xlat38 = (-_Gloss) + 1.0;
          
          u_xlat16_34 = (-u_xlat38) * 0.699999988 + 1.70000005;
          
          u_xlat16_34 = u_xlat16_34 * u_xlat38;
          
          u_xlat33 = dot(float2(u_xlat33,0), float2(u_xlat38,0));
          
          u_xlat33 = u_xlat33 + 0.5;
          
          u_xlat16_35 = u_xlat33 + -1.0;
          
          u_xlat16_34 = u_xlat16_34 * 6.0;
          
          u_xlat10_4 = textureCube(unity_SpecCube0, u_xlat5.xyz, u_xlat16_34);
          
          u_xlat16_34 = u_xlat10_4.w + -1.0;
          
          u_xlat16_34 = unity_SpecCube0_HDR.w * u_xlat16_34 + 1.0;
          
          u_xlat16_34 = u_xlat16_34 * unity_SpecCube0_HDR.x;
          
          u_xlat16_9.xyz = u_xlat10_4.xyz * float3(u_xlat16_34,0,0);
          
          u_xlat16_34 = -abs(u_xlat8) + 1.0;
          
          u_xlat33 = -abs(u_xlat8) + 1.0;
          
          u_xlat16_36 = u_xlat16_34 * u_xlat16_34;
          
          u_xlat16_36 = u_xlat16_36 * u_xlat16_36;
          
          u_xlat16_34 = u_xlat16_34 * u_xlat16_36;
          
          u_xlat16_36 = (-_Metallic) * 0.779083729 + 0.779083729;
          
          u_xlat5.x = (-u_xlat16_36) + 1.0;
          
          u_xlat16_1.xyz = u_xlat16_1.xyz * float3(u_xlat16_36,0,0);
          
          u_xlat5.x = u_xlat5.x + _Gloss;
          
          u_xlat5.x = clamp(u_xlat5.x, 0.0, 1.0);
          
          u_xlat16_10.xyz = (-u_xlat16_2.xyz) + u_xlat5.xxx;
          
          u_xlat16_2.xyz = float3(u_xlat16_34,0,0) * u_xlat16_10.xyz + u_xlat16_2.xyz;
          
          u_xlat5.xyz = u_xlat16_2.xyz * u_xlat16_9.xyz;
          
          u_xlat5.xyz = u_xlat6.xxx * u_xlat5.xyz;
          
          u_xlat5.xyz = u_xlat19.xyz * u_xlat16_3.xyz + u_xlat5.xyz;
          
          u_xlat16_34 = u_xlat33 * u_xlat33;
          
          u_xlat16_34 = u_xlat33 * u_xlat16_34;
          
          u_xlat16_34 = u_xlat33 * u_xlat16_34;
          
          u_xlat16_34 = u_xlat33 * u_xlat16_34;
          
          u_xlat33 = u_xlat16_35 * u_xlat16_34 + 1.0;
          
          u_xlat38 = (-u_xlat17) + 1.0;
          
          u_xlat16_34 = u_xlat38 * u_xlat38;
          
          u_xlat16_34 = u_xlat38 * u_xlat16_34;
          
          u_xlat16_34 = u_xlat38 * u_xlat16_34;
          
          u_xlat16_34 = u_xlat38 * u_xlat16_34;
          
          u_xlat38 = u_xlat16_35 * u_xlat16_34 + 1.0;
          
          u_xlat33 = u_xlat33 * u_xlat38;
          
          u_xlat33 = u_xlat17 * u_xlat33;
          
          u_xlat6.xyz = float3(u_xlat33,0,0) * _LightColor0.xyz;
          
          u_xlat5.xyz = u_xlat6.xyz * u_xlat16_1.xyz + u_xlat5.xyz;
          
          out_f.color.xyz = u_xlat10_0.xyz * _Color.xyz + u_xlat5.xyz;
          
          out_f.color.w = 1.0;
          
          return out_f;
      
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
      #pragma multi_compile DIRLIGHTMAP_OFF DYNAMICLIGHTMAP_OFF LIGHTMAP_OFF POINT
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
      
      uniform float _Metallic;
      
      uniform float _Gloss;
      
      uniform float4 _t1_ST;
      
      uniform float4 _t2_ST;
      
      uniform float4 _c;
      
      uniform float _2;
      
      uniform sampler2D _t1;
      
      uniform sampler2D _LightTexture0;
      
      uniform sampler2D _t2;
      
      
      
      struct appdata_t
      {
          
          float4 vertex : POSITION0;
          
          float3 normal : NORMAL0;
          
          float4 tangent : TANGENT0;
          
          float2 texcoord : TEXCOORD0;
          
          float2 texcoord1 : TEXCOORD1;
          
          float2 texcoord2 : TEXCOORD2;
      
      };
      
      
      struct OUT_Data_Vert
      {
          
          float2 texcoord : TEXCOORD0;
          
          float2 texcoord1 : TEXCOORD1;
          
          float2 texcoord2 : TEXCOORD2;
          
          float4 texcoord3 : TEXCOORD3;
          
          float3 texcoord4 : TEXCOORD4;
          
          float3 texcoord5 : TEXCOORD5;
          
          float3 texcoord6 : TEXCOORD6;
          
          float3 texcoord7 : TEXCOORD7;
          
          float4 vertex : SV_POSITION;
      
      };
      
      
      struct v2f
      {
          
          float2 texcoord : TEXCOORD0;
          
          float4 texcoord3 : TEXCOORD3;
          
          float3 texcoord4 : TEXCOORD4;
          
          float3 texcoord7 : TEXCOORD7;
      
      };
      
      
      struct OUT_Data_Frag
      {
          
          float4 color : SV_Target0;
      
      };
      
      
      float4 u_xlat0;
      
      float4 u_xlat1;
      
      float4 u_xlat2;
      
      float3 u_xlat3;
      
      float u_xlat13;
      
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
          
          out_v.texcoord1.xy = in_v.texcoord1.xy;
          
          out_v.texcoord2.xy = in_v.texcoord2.xy;
          
          out_v.texcoord3 = u_xlat0;
          
          u_xlat1.x = dot(in_v.normal.xyz, unity_WorldToObject[0].xyz);
          
          u_xlat1.y = dot(in_v.normal.xyz, unity_WorldToObject[1].xyz);
          
          u_xlat1.z = dot(in_v.normal.xyz, unity_WorldToObject[2].xyz);
          
          u_xlat13 = dot(u_xlat1.xyz, u_xlat1.xyz);
          
          u_xlat13 = sqrt(u_xlat13);
          
          u_xlat1.xyz = float3(u_xlat13) * u_xlat1.xyz;
          
          out_v.texcoord4.xyz = u_xlat1.xyz;
          
          u_xlat2.xyz = in_v.tangent.yyy * unity_ObjectToWorld[1].xyz;
          
          u_xlat2.xyz = unity_ObjectToWorld[0].xyz * in_v.tangent.xxx + u_xlat2.xyz;
          
          u_xlat2.xyz = unity_ObjectToWorld[2].xyz * in_v.tangent.zzz + u_xlat2.xyz;
          
          u_xlat13 = dot(u_xlat2.xyz, u_xlat2.xyz);
          
          u_xlat13 = sqrt(u_xlat13);
          
          u_xlat2.xyz = float3(u_xlat13) * u_xlat2.xyz;
          
          out_v.texcoord5.xyz = u_xlat2.xyz;
          
          u_xlat3.xyz = u_xlat1.zxy * u_xlat2.yzx;
          
          u_xlat1.xyz = u_xlat1.yzx * u_xlat2.zxy + (-u_xlat3.xyz);
          
          u_xlat1.xyz = u_xlat1.xyz * in_v.tangent.www;
          
          u_xlat13 = dot(u_xlat1.xyz, u_xlat1.xyz);
          
          u_xlat13 = sqrt(u_xlat13);
          
          out_v.texcoord6.xyz = float3(u_xlat13) * u_xlat1.xyz;
          
          u_xlat1.xyz = u_xlat0.yyy * unity_WorldToLight[1].xyz;
          
          u_xlat1.xyz = unity_WorldToLight[0].xyz * u_xlat0.xxx + u_xlat1.xyz;
          
          u_xlat0.xyz = unity_WorldToLight[2].xyz * u_xlat0.zzz + u_xlat1.xyz;
          
          out_v.texcoord7.xyz = unity_WorldToLight[3].xyz * u_xlat0.www + u_xlat0.xyz;
          
          return;
      
      }
      
      
      #define CODE_BLOCK_FRAGMENT
      
      
      
      
      float4 u_xlat0_d;
      
      float3 u_xlat10_0;
      
      int u_xlatb0;
      
      float3 u_xlat16_1;
      
      float3 u_xlat16_2;
      
      float3 u_xlat3_d;
      
      float3 u_xlat4;
      
      float3 u_xlat5;
      
      float u_xlat6;
      
      float3 u_xlat16_7;
      
      float3 u_xlat8;
      
      float3 u_xlat16_9;
      
      float3 u_xlat11;
      
      float u_xlat16;
      
      float u_xlat19;
      
      float u_xlat24;
      
      float u_xlat16_25;
      
      float u_xlat16_26;
      
      float u_xlat27;
      
      float u_xlat28;
      
      float u_xlat29;
      
      OUT_Data_Frag frag(v2f in_f)
      {
          
          u_xlat0_d.xy = in_f.texcoord.xy * _t1_ST.xy + _t1_ST.zw;
          
          u_xlat10_0.xy = tex2D(_t1, u_xlat0_d.xy).xz;
          
          u_xlat16_1.x = u_xlat10_0.y * 1.09200001;
          
          u_xlatb0 = u_xlat10_0.x>=_2;
          
          u_xlat16_9.x = (u_xlatb0) ? 1.0 : 0.0;
          
          u_xlatb0 = u_xlat16_1.x>=_2;
          
          if(!u_xlatb0)
      {
              discard;
      }
          
          u_xlat16_1.x = (u_xlatb0) ? 1.0 : 0.0;
          
          u_xlat0_d.xy = in_f.texcoord.xy * _t2_ST.xy + _t2_ST.zw;
          
          u_xlat10_0.xyz = tex2D(_t2, u_xlat0_d.xy).xyz;
          
          u_xlat16_2.xyz = u_xlat10_0.xyz + (-_c.xyz);
          
          u_xlat16_9.xyz = u_xlat16_9.xxx * u_xlat16_2.xyz + _c.xyz;
          
          u_xlat16_9.xyz = (-u_xlat10_0.xyz) + u_xlat16_9.xyz;
          
          u_xlat16_1.xyz = u_xlat16_1.xxx * u_xlat16_9.xyz + u_xlat10_0.xyz;
          
          u_xlat16_25 = (-_Metallic) * 0.779083729 + 0.779083729;
          
          u_xlat16_2.xyz = float3(u_xlat16_25) * u_xlat16_1.xyz;
          
          u_xlat16_1.xyz = u_xlat16_1.xyz + float3(-0.220916301, -0.220916301, -0.220916301);
          
          u_xlat16_1.xyz = float3(_Metallic) * u_xlat16_1.xyz + float3(0.220916301, 0.220916301, 0.220916301);
          
          u_xlat0_d.x = dot(u_xlat16_1.xyz, u_xlat16_1.xyz);
          
          u_xlatb0 = u_xlat0_d.x!=0.0;
          
          u_xlat0_d.x = u_xlatb0 ? 1.0 : float(0.0);
          
          u_xlat8.xyz = (-in_f.texcoord3.xyz) + _WorldSpaceCameraPos.xyz;
          
          u_xlat3_d.x = dot(u_xlat8.xyz, u_xlat8.xyz);
          
          u_xlat3_d.x = sqrt(u_xlat3_d.x);
          
          u_xlat11.xyz = u_xlat8.xyz * u_xlat3_d.xxx;
          
          u_xlat4.x = dot(in_f.texcoord4.xyz, in_f.texcoord4.xyz);
          
          u_xlat4.x = sqrt(u_xlat4.x);
          
          u_xlat4.xyz = u_xlat4.xxx * in_f.texcoord4.xyz;
          
          u_xlat11.x = dot(u_xlat4.xyz, u_xlat11.xyz);
          
          u_xlat5.xyz = _WorldSpaceLightPos0.www * (-in_f.texcoord3.xyz) + _WorldSpaceLightPos0.xyz;
          
          u_xlat19 = dot(u_xlat5.xyz, u_xlat5.xyz);
          
          u_xlat19 = sqrt(u_xlat19);
          
          u_xlat5.xyz = float3(u_xlat19) * u_xlat5.xyz;
          
          u_xlat19 = dot(u_xlat4.xyz, u_xlat5.xyz);
          
          u_xlat19 = max(u_xlat19, 0.0);
          
          u_xlat27 = min(u_xlat19, 1.0);
          
          u_xlat16_25 = (-_Gloss) + 1.0;
          
          u_xlat28 = (-u_xlat16_25) * u_xlat16_25 + 1.0;
          
          u_xlat29 = u_xlat16_25 * u_xlat16_25;
          
          u_xlat6 = u_xlat27 * u_xlat28 + u_xlat29;
          
          u_xlat28 = abs(u_xlat11.x) * u_xlat28 + u_xlat29;
          
          u_xlat29 = u_xlat29 * u_xlat29;
          
          u_xlat6 = abs(u_xlat11.x) * u_xlat6;
          
          u_xlat11.x = -abs(u_xlat11.x) + 1.0;
          
          u_xlat28 = u_xlat27 * u_xlat28 + u_xlat6;
          
          u_xlat28 = u_xlat28 + 9.99999975e-06;
          
          u_xlat28 = 0.5 / u_xlat28;
          
          u_xlat8.xyz = u_xlat8.xyz * u_xlat3_d.xxx + u_xlat5.xyz;
          
          u_xlat3_d.x = dot(u_xlat8.xyz, u_xlat8.xyz);
          
          u_xlat3_d.x = sqrt(u_xlat3_d.x);
          
          u_xlat8.xyz = u_xlat8.xyz * u_xlat3_d.xxx;
          
          u_xlat3_d.x = dot(u_xlat4.xyz, u_xlat8.xyz);
          
          u_xlat3_d.x = clamp(u_xlat3_d.x, 0.0, 1.0);
          
          u_xlat8.x = dot(u_xlat5.xyz, u_xlat8.xyz);
          
          u_xlat8.x = clamp(u_xlat8.x, 0.0, 1.0);
          
          u_xlat16 = u_xlat3_d.x * u_xlat29 + (-u_xlat3_d.x);
          
          u_xlat16 = u_xlat16 * u_xlat3_d.x + 1.0;
          
          u_xlat16 = u_xlat16 * u_xlat16 + 1.00000001e-07;
          
          u_xlat24 = u_xlat29 * 0.318309873;
          
          u_xlat16 = u_xlat24 / u_xlat16;
          
          u_xlat16 = u_xlat16 * u_xlat28;
          
          u_xlat16 = u_xlat16 * 3.14159274;
          
          u_xlat16 = max(u_xlat16, 9.99999975e-05);
          
          u_xlat16 = sqrt(u_xlat16);
          
          u_xlat16 = u_xlat27 * u_xlat16;
          
          u_xlat0_d.x = u_xlat0_d.x * u_xlat16;
          
          u_xlat16 = dot(in_f.texcoord7.xyz, in_f.texcoord7.xyz);
          
          u_xlat16 = tex2D(_LightTexture0, float2(u_xlat16)).x;
          
          u_xlat4.xyz = float3(u_xlat16) * _LightColor0.xyz;
          
          u_xlat0_d.xzw = u_xlat0_d.xxx * u_xlat4.xyz;
          
          u_xlat16_25 = (-u_xlat8.x) + 1.0;
          
          u_xlat8.x = dot(u_xlat8.xx, u_xlat8.xx);
          
          u_xlat16_26 = u_xlat16_25 * u_xlat16_25;
          
          u_xlat16_26 = u_xlat16_26 * u_xlat16_26;
          
          u_xlat16_25 = u_xlat16_25 * u_xlat16_26;
          
          u_xlat16_7.xyz = (-u_xlat16_1.xyz) + float3(1.0, 1.0, 1.0);
          
          u_xlat16_1.xyz = u_xlat16_7.xyz * float3(u_xlat16_25) + u_xlat16_1.xyz;
          
          u_xlat0_d.xzw = u_xlat0_d.xzw * u_xlat16_1.xyz;
          
          u_xlat16_1.x = u_xlat11.x * u_xlat11.x;
          
          u_xlat16_1.x = u_xlat11.x * u_xlat16_1.x;
          
          u_xlat16_1.x = u_xlat11.x * u_xlat16_1.x;
          
          u_xlat16_1.x = u_xlat11.x * u_xlat16_1.x;
          
          u_xlat3_d.x = (-_Gloss) + 1.0;
          
          u_xlat8.x = u_xlat8.x * u_xlat3_d.x + 0.5;
          
          u_xlat16_9.x = u_xlat8.x + -1.0;
          
          u_xlat8.x = u_xlat16_9.x * u_xlat16_1.x + 1.0;
          
          u_xlat3_d.x = (-u_xlat19) + 1.0;
          
          u_xlat16_1.x = u_xlat3_d.x * u_xlat3_d.x;
          
          u_xlat16_1.x = u_xlat3_d.x * u_xlat16_1.x;
          
          u_xlat16_1.x = u_xlat3_d.x * u_xlat16_1.x;
          
          u_xlat16_1.x = u_xlat3_d.x * u_xlat16_1.x;
          
          u_xlat3_d.x = u_xlat16_9.x * u_xlat16_1.x + 1.0;
          
          u_xlat8.x = u_xlat8.x * u_xlat3_d.x;
          
          u_xlat8.x = u_xlat19 * u_xlat8.x;
          
          u_xlat3_d.xyz = u_xlat4.xyz * u_xlat8.xxx;
          
          out_f.color.xyz = u_xlat3_d.xyz * u_xlat16_2.xyz + u_xlat0_d.xzw;
          
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
      #pragma multi_compile DIRLIGHTMAP_OFF DYNAMICLIGHTMAP_OFF LIGHTMAP_OFF SHADOWS_DEPTH
      //#pragma target 4.0
      
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      
      
      #define CODE_BLOCK_VERTEX
      
      
      uniform float4 unity_LightShadowBias;
      
      uniform float4 unity_ObjectToWorld[4];
      
      uniform float4 unity_MatrixVP[4];
      
      uniform float4 _t1_ST;
      
      uniform float _2;
      
      uniform sampler2D _t1;
      
      
      
      struct appdata_t
      {
          
          float4 vertex : POSITION0;
          
          float2 texcoord : TEXCOORD0;
          
          float2 texcoord1 : TEXCOORD1;
          
          float2 texcoord2 : TEXCOORD2;
      
      };
      
      
      struct OUT_Data_Vert
      {
          
          float2 texcoord1 : TEXCOORD1;
          
          float2 texcoord2 : TEXCOORD2;
          
          float2 texcoord3 : TEXCOORD3;
          
          float4 texcoord4 : TEXCOORD4;
          
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
          
          u_xlat1 = u_xlat0 + unity_ObjectToWorld[3];
          
          out_v.texcoord4 = unity_ObjectToWorld[3] * in_v.vertex.wwww + u_xlat0;
          
          u_xlat0 = u_xlat1.yyyy * unity_MatrixVP[1];
          
          u_xlat0 = unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat0;
          
          u_xlat0 = unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat0;
          
          u_xlat0 = unity_MatrixVP[3] * u_xlat1.wwww + u_xlat0;
          
          u_xlat1.x = unity_LightShadowBias.x / u_xlat0.w;
          
          u_xlat1.x = clamp(u_xlat1.x, 0.0, 1.0);
          
          u_xlat4 = u_xlat0.z + u_xlat1.x;
          
          u_xlat1.x = max((-u_xlat0.w), u_xlat4);
          
          out_v.vertex.xyw = u_xlat0.xyw;
          
          u_xlat0.x = (-u_xlat4) + u_xlat1.x;
          
          out_v.vertex.z = unity_LightShadowBias.y * u_xlat0.x + u_xlat4;
          
          out_v.texcoord1.xy = in_v.texcoord.xy;
          
          out_v.texcoord2.xy = in_v.texcoord1.xy;
          
          out_v.texcoord3.xy = in_v.texcoord2.xy;
          
          return;
      
      }
      
      
      #define CODE_BLOCK_FRAGMENT
      
      
      
      
      float2 u_xlat0_d;
      
      float u_xlat10_0;
      
      int u_xlatb0;
      
      float u_xlat16_1;
      
      OUT_Data_Frag frag(v2f in_f)
      {
          
          u_xlat0_d.xy = in_f.texcoord1.xy * _t1_ST.xy + _t1_ST.zw;
          
          u_xlat10_0 = tex2D(_t1, u_xlat0_d.xy).z;
          
          u_xlat16_1 = u_xlat10_0 * 1.09200001;
          
          u_xlatb0 = u_xlat16_1>=_2;
          
          if(!u_xlatb0)
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
