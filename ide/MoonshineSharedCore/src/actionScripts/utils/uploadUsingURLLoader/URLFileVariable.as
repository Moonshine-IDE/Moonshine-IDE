/*
  Copyright (c) Mike Stead 2009, All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.

  * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.

  * Neither the name of Adobe Systems Incorporated nor the names of its
    contributors may be used to endorse or promote products derived from
    this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
  IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
package actionScripts.utils.uploadUsingURLLoader
{
    import flash.utils.ByteArray;

    /**
     * The URLFileVariable class wraps file data to be sent to the server using a URLRequest.
     *
     * <p>To add an instance of URLFileVariable to a URLRequest you must first create a URLVariables
     * instance and then set one or more of its properties with a URLFileVariable instance. This
     * URLVariables instance should then be passed to a URLRequestBuilder which can construct
     * the URLRequest with the correct encoding to transport the file(s) to the server.</p>
     *
     * @example
     * <pre>
     * // Construct variables (name-value pairs) to be sent to sever
     * var variables:URLVariable = new URLVariables();
     * variables.userImage = new URLFileVariable(jpegEncodedData, "user_image.jpg");
     * variables.userPDF = new URLFileVariable(pdfEncodedData, "user_doc.pdf");
     * variables.userName = "Mike";
     * // Build the request which houses these variables
     * var request:URLRequest = new URLRequestBuilder(variables).build();
     * request.url = "some.web.address.php";
     * // Create the loader and use it to send the request off to the server
     * var loader:URLLoader = new URLLoader();
     * loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
     * loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onError);
     * loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
     * loader.addEventListener(Event.COMPLETE, onServerResponse);
     * loader.load(request);
     * function onServerResponse(event:Event):void
     * {
     *     trace("Variables uploaded successfully");
     * }
     * function onError(event:Event):void
     * {
     *     trace("An error occured while trying to upload data to the server: \n" + event);
     * }
     * </pre>
     *
     * @author Mike Stead
     * @see URLRequestBuilder
     */
    public class URLFileVariable
    {
        private var _name:String;
        private var _data:ByteArray;

        /**
         * Constructor.
         *
         * @param data The contents of the file to be sent to the server
         * @param name The name to be given to the file on the server, e.g. <code>user_image.jpg</code>
         */
        public function URLFileVariable(data:ByteArray, name:String)
        {
            _data = data;
            _name = name;
        }

        /**
         * The name to be given to the file on the server
         */
        public function get name():String
        {
            return _name;
        }

        /**
         * The contents of the file
         */
        public function get data():ByteArray
        {
            return _data;
        }
    }
}