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
    import flash.net.URLRequestHeader;
    import flash.net.URLRequestMethod;
    import flash.net.URLRequest;
    import flash.net.URLVariables;
    import flash.utils.ByteArray;

    /**
     * The <code>URLRequestBuilder</code> class takes an instance of <code>URLVariables</code>
     * and wraps these variables in a <code>URLRequest</code> with the appropriate HTTP encoding.
     *
     * This class is needed to build URLRequest objects with encodings not automatically applied
     * when the <code>URLRequest.data</code> property is set.
     *
     * <p>To determine the correct encoding to apply, each variable in the <code>URLVariables</code>
     * instance is examined. If a variable of type <code>URLFileVariable</code> is found
     * then the encoding is set to <code>multipart/form-data</code>, and the
     * <code>URLRequest.method</code> set to POST. If no <code>URLFileVariable</code> is found
     * then the <code>URLRequest.data</code> property is set with the <code>URLVariables</code>
     * instance directly. To see the encoding used in this case refer to the documentation for the
     * <code>URLRequest.data</code> property</p>.
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
     *     trace("An error occurred while trying to upload data to the server: \n" + event);
     * }
     * </pre>
     *
     * @author Mike Stead
     * @see URLFileVariable
     */
    public class URLRequestBuilder
    {
        private static const MULTIPART_BOUNDARY:String  = "----------196f00b77b968397849367c61a2080";
        private static const MULTIPART_MARK:String      = "--";
        private static const LF:String                  = "\r\n";

        /** The variables to encode within a URLRequest */
        private var variables:URLVariables;

        /**
         * Constructor.
         *
         * @param variables The URLVariables to encode within a URLRequest.
         */
        public function URLRequestBuilder(variables:URLVariables)
        {
             this.variables = variables;
        }

        /**
         * Build a URLRequest instance with the correct encoding given the URLVariables
         * provided to the constructor.
         *
         * @return URLRequest instance primed and ready for submission
         */
        public function build():URLRequest
        {
            var request:URLRequest = new URLRequest();
            if (isMultipartData)
            {
                request.data = buildMultipartBody();
                addMultipartHeadersTo(request);
            }
            else
            {
                request.data = variables;
            }
            return request;
        }

        /**
         * Determines whether, given the URLVariables instance provided to the constructor, the
         * URLRequest should be encoded using <code>multipart/form-data</code>.
         */
        private function get isMultipartData():Boolean
        {
            for each (var variable:* in variables)
            {
                if (variable is URLFileVariable)
                    return true;
            }
            return false;
        }

        /**
         * Build a ByteArray instance containing the <code>multipart/form-data</code> encoded URLVariables.
         *
         * @return ByteArray containing the encoded variables
         */
        private function buildMultipartBody():ByteArray
        {
            var body:ByteArray = new ByteArray();

            // Write each encoded field into the request body
            for (var id:String in variables)
                body.writeBytes(encodeMultipartVariable(id, variables[id]));

            // Mark the end of the request body
            // Note, we writeUTFBytes and not writeUTF because it can corrupt parsing on the server
            body.writeUTFBytes(MULTIPART_MARK + MULTIPART_BOUNDARY + MULTIPART_MARK + LF);
            return body;
        }

        /**
         * Encode a variable using <code>multipart/form-data</code>.
         *
         * @param id    The unique id of the variable
         * @param value The value of the variable
         */
        private function encodeMultipartVariable(id:String, variable:Object):ByteArray
        {
            if (variable is URLFileVariable)
                return encodeMultipartFile(id, URLFileVariable(variable));
            else
                return encodeMultipartString(id, variable.toString());
        }

        /**
         * Encode a file using <code>multipart/form-data</code>.
         *
         * @param id   The unique id of the file variable
         * @param file The URLFileVariable containing the file name and file data
         *
         * @return The encoded variable
         */
        private function encodeMultipartFile(id:String, file:URLFileVariable):ByteArray
        {
            var field:ByteArray = new ByteArray();
            // Note, we writeUTFBytes and not writeUTF because it can corrupt parsing on the server
            field.writeUTFBytes(MULTIPART_MARK + MULTIPART_BOUNDARY + LF +
                                "Content-Disposition: form-data; name=\"" + id +  "\"; " +
                                "filename=\"" + file.name + "\"" + LF +
                                "Content-Type: application/octet-stream" + LF + LF);

            field.writeBytes(file.data);
            field.writeUTFBytes(LF);
            return field;
        }

        /**
         * Encode a string using <code>multipart/form-data</code>.
         *
         * @param id   The unique id of the string
         * @param text The value of the string
         *
         * @return The encoded variable
         */
        private function encodeMultipartString(id:String, text:String):ByteArray
        {
            var field:ByteArray = new ByteArray();
            // Note, we writeUTFBytes and not writeUTF because it can corrupt parsing on the server
            field.writeUTFBytes(MULTIPART_MARK + MULTIPART_BOUNDARY + LF +
                                "Content-Disposition: form-data; name=\"" + id + "\"" + LF + LF +
                                text + LF);
            return field;
        }

        /**
         * Add the relevant <code>multipart/form-data</code> headers to a URLRequest.
         */
        private function addMultipartHeadersTo(request:URLRequest):void
        {
            request.method         = URLRequestMethod.POST;
            request.contentType    = "multipart/form-data; boundary=" + MULTIPART_BOUNDARY;
            request.requestHeaders =
            [
                new URLRequestHeader("Accept", "*/*"), // Allow any type of data in response
                new URLRequestHeader("Cache-Control", "no-cache")
            ];

            // Note, the headers: Content-Length and Connection:Keep-Alive are auto set by URLRequest
        }
    }
}