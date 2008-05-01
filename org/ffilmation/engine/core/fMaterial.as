// The Material Class provides an abstract interface between the Engine and the user defined materials
package org.ffilmation.engine.core {
	
		// Imports
		import flash.display.*
		import flash.geom.*
		import flash.utils.getDefinitionByName
		import org.ffilmation.engine.core.*
		import org.ffilmation.engine.elements.*
		import org.ffilmation.engine.helpers.*
		import org.ffilmation.engine.interfaces.*
		import org.ffilmation.engine.materials.*
	  
		/**
		* <p>Every Plane (walls and floors) in the scene is assigned a Material. The fMaterial Class is used as an interface
		* between the engine and the user-defined materials. The engine provides four material types:</p>
		*
		*	<p> "tile" an image will be used and tiled to fill the surface</p>
		*	<p> "perlin" A perlin noise material that stacks several "tile" materials to create a more realistic surface</p>
		*	<p> "clip" a movieClip from your library will be used as material an scaled to fit each surface's dimensions</p>
		*	<p> "procedural" you specify a class that will be used as material. This class needs to implement the fEngineMaterial interface</p>
		*
		* <p>Each will end up in a different class being instantiated. See sample XMLs to see how materials are defined</p>
		*
		* <p>This class is used internally only</p>
		*
		* @see org.ffilmation.engine.interfaces.fEngineMaterial
		* @see org.ffilmation.engine.materials.fTileMaterial
		* @see org.ffilmation.engine.materials.fPerlinMaterial
		* @see org.ffilmation.engine.materials.fClipMaterial
		*
		*/
		public class fMaterial {
		
			// Static properties

			// Private properties
			private var element:fRenderableElement			// The element where this material is applied
			private var type:String				    					// Material type
			private var cls:fEngineMaterial							// The class that generates the material
			private var definitionXML:XML								// Definition data
			private var width:Number										// Size
			private var height:Number
			
			// Constructor
			/** @private */
			function fMaterial(id:String,width:Number,height:Number,element:fRenderableElement):void {

				 // Make sure this material has a definition in the scene. If it doesn't, throw an error
				 try {

				 		this.element = element
				 		this.definitionXML = element.scene.materialDefinitions[id].copy()
				 		this.width = width
				 		this.height = height
				 		this.type = this.definitionXML.@type
				 		this.cls = null
				 		if(this.type == "tile") this.cls = new fTileMaterial(this.definitionXML)
				 		else if(this.type == "perlin") this.cls = new fPerlinMaterial(this.definitionXML,element)
				 		else if(this.type == "door") this.cls = new fDoorMaterial(this.definitionXML,element)
				 		else if(this.type == "clip") this.cls = new fClipMaterial(this.definitionXML)
				 		else if(this.type == "procedural") {
				 			var r:Class = getDefinitionByName(this.definitionXML.classname[0]) as Class
				 			this.cls = new r(this.definitionXML)
				 		}
				 
				 } catch (e:Error) {
				 		throw new Error("Filmation Engine Exception: The scene does not contain a valid material definition that matches definition id '"+id+" : "+e)
				 }

				
			}

			/** @private */
			public function getDiffuse():DisplayObject {
				var s:DisplayObject = this.cls.getDiffuse(this.width,this.height)
				var r:Sprite = new Sprite()
				r.addChild(s)
				if(this.element is fWall) s.y = -this.height
				return r
			}

			/** @private */
			public function getBump():DisplayObject {
				var s:DisplayObject = this.cls.getBump(this.width,this.height)
				var r:Sprite = new Sprite()
				r.addChild(s)
				if(this.element is fWall) s.y = -this.height
				return r
			}

			/** @private */
			public function getHoles():Array {
				
				var t:Array = this.cls.getHoles(this.width,this.height)
				var ret:Array = []
				
				// Convert holes to floor coordinates
				if(this.element is fFloor) {
						for(var c:Number=0;c<t.length;c++) {
						  var mcontainer:Rectangle = t[c]
							var nobj:fPlaneBounds = new fPlaneBounds()
							nobj.z = this.element.z
							nobj.xrel = mcontainer.x
							nobj.yrel = mcontainer.y
							nobj.x0 = nobj.x = this.element.x+mcontainer.x
							nobj.y0 = nobj.y = this.element.y+mcontainer.y-mcontainer.height
							nobj.width = mcontainer.width
							nobj.height = mcontainer.height
							nobj.x1 = nobj.x0+nobj.width  
							nobj.y1 = nobj.y0+nobj.height  
							ret[ret.length] = nobj
						}
        }

				// Convert holes to wall coordinates
				else if(this.element is fWall) {

						var el:fWall = this.element as fWall

						for(c=0;c<t.length;c++) {
						  mcontainer = t[c]
						  mcontainer.offset(0,-this.height)
			        nobj = new fPlaneBounds()
							nobj.z = el.z-mcontainer.y
							nobj.top = el.z-mcontainer.y+mcontainer.height

							nobj.xrel = mcontainer.x
							nobj.yrel = mcontainer.y
							nobj.width = mcontainer.width
							nobj.height = mcontainer.height

							if(el.vertical) {
								nobj.vertical = true
								nobj.x = el.x
								nobj.x0 = el.x
								nobj.x1 = el.x
								nobj.y = nobj.y0 = el.y+mcontainer.x
								nobj.y1 = el.y+mcontainer.x+mcontainer.width
							} else {
							  nobj.vertical = false
								nobj.y = el.y
								nobj.x = nobj.x0 = el.x+mcontainer.x
								nobj.x1 = el.x+mcontainer.x+mcontainer.width
								nobj.y0 = el.y
								nobj.y1 = el.y
						  }
						  
							ret[ret.length] = nobj
						}
				
			  }
				
				return ret
			}

		}

}