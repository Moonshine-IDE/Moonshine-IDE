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

package com.palantir.ls.api;

import java.util.List;
import org.eclipse.lsp4j.TextDocumentContentChangeEvent;

/**
 * Manages the contents of a file.
 */
public interface ContentsManager {

    /**
     * Applies the specified changes to the file.
     */
    void applyChanges(List<TextDocumentContentChangeEvent> contentChanges);

    /**
     * Returns the current contents of the file.
     */
    String getContents();

    /**
     * Reloads the contents of the file from the backing store.
     * <p>
     * Typically, this means that any changes that have been applied via {@link #applyChanges(List)} are discarded.
     */
    void reload();

    /**
     * Save changes to the backing store.
     */
    void saveChanges();

}
