// A point in 3D
package org.ffilmation.engine.datatypes {

		import org.ffilmation.utils.*
		
		/**
		* This object stores a tridimensional point
		*/
		public class fPoint3d {
		
			/** X coordinate */
			public var x:Number

			/** Scene Y coordinate */
			public var y:Number

			/** Scene Z coordinate */
			public var z:Number
			
			/**
			* Constructor for the fPoint3d class
			*/
			function fPoint3d(x:Number,y:Number,z:Number):void {
				 this.x = x
				 this.y = y
				 this.z = z
			}
			
			/**
			* Return distance to another 3dPoint
			*
			* @param other Point to be comapred
			*
			* @return Distance betwenn points
			*/
			public function distanceTo(other:fPoint3d) {
				return mathUtils.distance3d(this.x,this.y,this.z,other.x,other.y,other.z)
			}

			/** @private */
			public function toString():String {
				return ("fPoint3d: "+x+", "+y+", "+z)
			}
			
		}
}

