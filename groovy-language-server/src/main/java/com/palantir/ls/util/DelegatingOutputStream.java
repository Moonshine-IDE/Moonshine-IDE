/*
 * Copyright 2017 Palantir Technologies, Inc. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.palantir.ls.util;

import com.google.common.base.Preconditions;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.util.function.Consumer;

public class DelegatingOutputStream extends OutputStream {

    private static final int DEFAULT_BUFFER_LENGTH = 4096;

    private final Consumer<String> stringConsumer;

    private byte[] buffer = new byte[DEFAULT_BUFFER_LENGTH];
    private int count = 0;
    private int currentBufferSize = DEFAULT_BUFFER_LENGTH;
    private boolean closed = false;

    public DelegatingOutputStream(Consumer<String> stringConsumer) {
        this.stringConsumer = stringConsumer;
    }

    @Override
    public void write(final int byteToWrite) throws IOException {
        Preconditions.checkState(!closed, "Attempted to write to a closed stream.");
        if (count >= currentBufferSize) {
            int newSize = currentBufferSize + DEFAULT_BUFFER_LENGTH;
            byte[] newBuffer = new byte[newSize];
            System.arraycopy(buffer, 0, newBuffer, 0, currentBufferSize);
            buffer = newBuffer;
            currentBufferSize = newSize;
        }
        buffer[count] = (byte) byteToWrite;
        count++;
    }

    @Override
    public void flush() {
        String str = new String(buffer, StandardCharsets.UTF_8);
        stringConsumer.accept(str);
        count = 0;
    }

    @Override
    public void close() throws IOException {
        flush();
        closed = true;
    }
}
