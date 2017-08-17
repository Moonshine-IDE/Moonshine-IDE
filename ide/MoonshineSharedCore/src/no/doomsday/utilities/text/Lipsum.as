////////////////////////////////////////////////////////////////////////////////
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
// 
////////////////////////////////////////////////////////////////////////////////
package no.doomsday.utilities.text
{
	public class Lipsum{
		private static const lipsum:String = "Sed ut perspiciatis, unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt, explicabo. Nemo enim ipsam voluptatem, quia voluptas sit, aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos, qui ratione voluptatem sequi nesciunt, neque porro quisquam est, qui dolorem ipsum, quia dolor sit, amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt, ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit, qui in ea voluptate velit esse, quam nihil molestiae consequatur, vel illum, qui dolorem eum fugiat, quo voluptas nulla pariatur? At vero eos et accusamus et iusto odio dignissimos ducimus, qui blanditiis praesentium voluptatum deleniti atque corrupti, quos dolores et quas molestias excepturi sint, obcaecati cupiditate non provident, similique sunt in culpa, qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio, cumque nihil impedit, quo minus id, quod maxime placeat, facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet, ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.";
		private static function shuffle(array:Array):Array{
			var arx:Array = array.concat();
			for(var i:Number=0;i<array.length;i++){
				var tmp:String = arx[i];
				var randomNum:Number = Math.floor(Math.random() * (arx.length-1));
				arx[i]=arx[randomNum];
				arx[randomNum]=tmp;
			}
			return arx;
		}
		/**
		 * Get some random lipsum text
		 * @param	length
		 * The number of chars to get
		 * @return
		 * A string
		 */
		public static function getText(length:int):String {
			var tmpString:Array = [];
			var lipSplit:Array = lipsum.split(" ");
			lipSplit = shuffle(lipSplit);
			for(var i:Number = 200;i--;){
				tmpString.push(lipSplit[i]);
			}
			var my_str:String = tmpString.join(" ");
			my_str = my_str.substr(0, length);
			var a:Array = my_str.split("");
			while (a[0] == " ") a.shift();
			while (a[a.length - 1] == " ") a.pop();
			a = a.join("").split("");
			a[0] = a[0].toUpperCase();
			return a.join("");
		}
	}
}