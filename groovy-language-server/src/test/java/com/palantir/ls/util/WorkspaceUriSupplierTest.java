/*
 * Copyright 2016 Palantir Technologies, Inc. All rights reserved.
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

import static org.junit.Assert.assertEquals;

import java.io.IOException;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.rules.TemporaryFolder;

public class WorkspaceUriSupplierTest {

    @Rule
    public ExpectedException expectedException = ExpectedException.none();

    @Rule
    public TemporaryFolder root = new TemporaryFolder();

    @Rule
    public TemporaryFolder other = new TemporaryFolder();

    @Test
    public void testConstructor_nonDirectoryWorkspaceRoot() throws IOException {
        expectedException.expect(IllegalArgumentException.class);
        expectedException.expectMessage("workspaceRoot must be a directory");
        new WorkspaceUriSupplier(root.newFile().toPath(), other.getRoot().toPath());
    }

    @Test
    public void testConstructor_nonDirectoryOther() throws IOException {
        expectedException.expect(IllegalArgumentException.class);
        expectedException.expectMessage("other must be a directory");
        new WorkspaceUriSupplier(root.getRoot().toPath(), other.newFile().toPath());
    }

    private WorkspaceUriSupplier getWorkspaceUriSupplier() {
        return new WorkspaceUriSupplier(root.getRoot().toPath(), other.getRoot().toPath());
    }

    @Test
    public void testGet() throws IOException {
        WorkspaceUriSupplier supplier = getWorkspaceUriSupplier();
        String expectedPathUri = root.getRoot().toPath().resolve("my/path").toUri().toString();
        String expectedFileUri = root.getRoot().toPath().resolve("my/file.txt").toUri().toString();
        assertEquals(expectedPathUri, supplier.get(root.getRoot().toPath().resolve("my/path").toUri()).toString());
        assertEquals(expectedPathUri, supplier.get(other.getRoot().toPath().resolve("my/path").toUri()).toString());
        assertEquals(expectedFileUri, supplier.get(root.getRoot().toPath().resolve("my/file.txt").toUri()).toString());
        assertEquals(expectedFileUri, supplier.get(other.getRoot().toPath().resolve("my/file.txt").toUri()).toString());
    }

}
