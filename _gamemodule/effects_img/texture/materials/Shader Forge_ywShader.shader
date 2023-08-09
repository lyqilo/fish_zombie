Shader "Shader Forge/ywShader"
{
  Properties
  {
    [HDR] _zhongColor ("zhongColor", Color) = (1,1,1,1)
    _node_9790 ("node_9790", Range(0, 4)) = 0.3684145
    _zhong ("zhong", float) = 1
    _xue ("xue", Range(-3, 10)) = 0.6151937
    _node_dise01 ("node_dise01", float) = 1
    [HDR] _node_dise02 ("node_dise02", Color) = (0.5,0.5,0.5,1)
    _MainTex ("MainTex", 2D) = "white" {}
    _node_943 ("node_943", 2D) = "white" {}
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
      Blend DstAlpha OneMinusSrcAlpha
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
      
      uniform float4 _zhongColor;
      
      uniform float4 _MainTex_ST;
      
      uniform float _node_9790;
      
      uniform float _zhong;
      
      uniform float4 _node_943_ST;
      
      uniform float _xue;
      
      uniform float _node_dise01;
      
      uniform float4 _node_dise02;
      
      uniform sampler2D _MainTex;
      
      uniform sampler2D _node_943;
      
      
      
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
          
          return out_v;
      
      }
      
      
      #define CODE_BLOCK_FRAGMENT
      
      
      
      
      float2 u_xlat0_d;
      
      float4 u_xlat1_d;
      
      float3 u_xlat10_1;
      
      float3 u_xlat10_2;
      
      float3 u_xlat3;
      
      float2 u_xlat6;
      
      OUT_Data_Frag frag(v2f in_f)
      {
          OUT_Data_Frag out_f;
          
          u_xlat0_d.xy = in_f.texcoord.xy + float2(-0.5, -0.5);
          
          u_xlat0_d.x = dot(u_xlat0_d.xy, u_xlat0_d.xy);
          
          u_xlat0_d.x = sqrt(u_xlat0_d.x);
          
          u_xlat0_d.x = log2(u_xlat0_d.x);
          
          u_xlat3.x = exp2(_xue);
          
          u_xlat3.x = u_xlat0_d.x * u_xlat3.x;
          
          u_xlat3.x = exp2(u_xlat3.x);
          
          u_xlat6.x = _Time.y + _TimeEditor.y;
          
          u_xlat1_d = u_xlat6.xxxx * float4(0.0299999993, -0.0199999996, 0.0500000007, 0.0199999996) + in_f.texcoord.xyxy;
          
          u_xlat6.xy = u_xlat1_d.zw * _node_943_ST.xy + _node_943_ST.zw;
          
          u_xlat1_d.xy = u_xlat1_d.xy * _MainTex_ST.xy + _MainTex_ST.zw;
          
          u_xlat10_1.xyz = tex2D(_MainTex, u_xlat1_d.xy).xyz;
          
          u_xlat1_d.xyz = u_xlat10_1.xyz * float3(float3(_node_dise01, _node_dise01, _node_dise01));
          
          u_xlat1_d.xyz = u_xlat1_d.xyz * _node_dise02.xyz;
          
          u_xlat10_2.xyz = tex2D(_node_943, u_xlat6.xy).xyz;
          
          u_xlat3.xyz = u_xlat3.xxx * u_xlat10_2.xyz;
          
          u_xlat3.xyz = u_xlat3.xyz * _zhongColor.xyz;
          
          u_xlat3.xyz = u_xlat3.xyz * float3(float3(_zhong, _zhong, _zhong));
          
          out_f.color.xyz = u_xlat3.xyz * u_xlat1_d.xyz;
          
          u_xlat3.x = exp2(_node_9790);
          
          u_xlat0_d.x = u_xlat0_d.x * u_xlat3.x;
          
          out_f.color.w = exp2(u_xlat0_d.x);
          
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
  FallBack "Diffuse"
}
