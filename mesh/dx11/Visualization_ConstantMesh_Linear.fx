//@author: tmp
//@help: Constant Shader for the Kinect Mesh
//@tags: DX11, Pointcloud, Mesh
//@credits: 

//Texture2D texture2d <string uiname="Texture";>;
Texture2D texRGB <string uiname="RGB";>;
Texture2D texRGBDepth <string uiname="RGBDepth";>;

SamplerState sPoint : IMMUTABLE
{
    Filter = MIN_MAG_MIP_POINT;
    AddressU = Border;
    AddressV = Border;
};
// Added  this section
SamplerState sLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Border;
    AddressV = Border;
};
// linear sampler

cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;	
};

cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
};

struct VS_IN
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;
};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
};

vs2ps VS(VS_IN input)
{
    vs2ps output;
    output.PosWVP  = mul(input.PosO,mul(tW,tVP));
    output.TexCd = input.TexCd;
    return output;
}

float4 PS(vs2ps In): SV_Target
{
    float2 coords = texRGBDepth.SampleLevel(sLinear,In.TexCd.xy,0).rg; // sampling with linear filter
    return texRGB.SampleLevel(sLinear,coords,0)* cAmb;  // sampling with linear filter
}

technique10 RGB
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}