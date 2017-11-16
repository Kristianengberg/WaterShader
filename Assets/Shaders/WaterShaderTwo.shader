// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/WaterShaderTwo"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,0.5)
		_Waves("Amount of Waves", range(0,5)) = 0
		_Amplitude("Amplitude", range(0,1)) = 0.1
		_Transparency("Transparency", range(0.0,1)) = 0.25
		_Raindrops("Raindrops", range(0,50)) = 50
		_RainAmplitude("Amplitude of Raindrops", range(0,1)) = 0.5


	}
	SubShader
	{
		Tags {"Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100

		ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

		GrabPass { "_GrabTexture"}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _GrabTexture;

			float4 _Color;
			float _Waves;
			float _Amplitude;
			float _Transparency;
			int _Raindrops;
			float _RainAmplitude;

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 color : COLOR;
				float4 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 grabPos : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
				float4 vertex : SV_POSITION;
				float4 color : COLOR;

			};


			v2f vert (appdata v)
			{
				v2f o;
				
				

				half offsetvert = _Amplitude*sin((v.vertex.x+_Time[1])/_Waves);
				v.vertex.y += v.vertex.y + offsetvert;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.uv = v.uv;
				o.grabPos = ComputeGrabScreenPos(o.vertex);
				

				return o;
			}
			


			fixed4 frag (v2f i) : SV_Target
			{



				i.grabPos.y += (_WorldSpaceCameraPos.y - i.vertex.y);
				//i.grabPos.z += (_WorldSpaceCameraPos.z - i.vertex.z);
				
				//i.grabPos.y += i.vertex.y;

			
				half4 refl = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.grabPos));

				return refl * _Color;
			}
			ENDCG
		}
	}
}
