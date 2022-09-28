package main;

import kha.graphics4.BlendingFactor;
import kha.Shaders;
import kha.graphics4.VertexStructure;
import kha.graphics4.PipelineState;

class Pipelines {
	public static var FADE_TO_WHITE(default, null): Null<PipelineState>;

	public static function init() {
		final emptryStructure = new VertexStructure();
		emptryStructure.add("vertexPosition", Float3);
		emptryStructure.add("vertexUV", Float2);
		emptryStructure.add("vertexColor", Float4);

		final ftw = new PipelineState();

		ftw.inputLayout = [emptryStructure];
		ftw.vertexShader = Shaders.painter_image_vert;
		ftw.fragmentShader = Shaders.fade_to_white_frag;
		ftw.blendSource = BlendingFactor.BlendOne;
		ftw.blendDestination = BlendingFactor.InverseSourceAlpha;
		ftw.alphaBlendSource = BlendingFactor.SourceAlpha;
		ftw.alphaBlendDestination = BlendingFactor.SourceAlpha;
		ftw.compile();

		FADE_TO_WHITE = ftw;
	}
}
