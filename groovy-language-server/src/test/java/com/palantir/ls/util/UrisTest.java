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
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import java.nio.file.Paths;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.rules.TemporaryFolder;

public class UrisTest {

    @Rule
    public ExpectedException expectedException = ExpectedException.none();

    @Rule
    public TemporaryFolder root = new TemporaryFolder();

    @Test
    public void testIsFileUri() {
        assertTrue(Uris.isFileUri("file:/var/my/path/to/something"));
        assertTrue(Uris.isFileUri("file:///var/my/path/to/something"));
        assertTrue(Uris.isFileUri("file:////var/my/path/to/something"));
        assertTrue(Uris.isFileUri("file://///var/my/path/to/something"));
        assertTrue(Uris.isFileUri("file:/var/my/path/to/something/file.txt"));
        assertFalse(Uris.isFileUri("file://var/my/path/to/something"));
        assertFalse(Uris.isFileUri("/var/my/path/to/something"));
        assertFalse(Uris.isFileUri("/var/my/path/to/something/file.txt"));
        assertFalse(Uris.isFileUri("var/my/path/to/something"));
        assertFalse(Uris.isFileUri("var/my/path/to/something/file.txt"));
        // Non file
        assertFalse(Uris.isFileUri("abc://username:password@example.com:123/path/data?key=value&key2=value2#fragid1"));
    }

    @Test
    public void testGetAbsolutePath() {
        String uri = "file:" + root.getRoot().getAbsolutePath();
        String absolutePath = root.getRoot().getAbsolutePath() + "/something/somethingelse/../somethingelse/./../..";
        String relativePath = "foo/something/somethingelse/../somethingelse/./../..";
        assertEquals(root.getRoot().getAbsolutePath(), Uris.getAbsolutePath(uri).toString());
        assertEquals(root.getRoot().getAbsolutePath(), Uris.getAbsolutePath(absolutePath).toString());
        assertEquals(Paths.get("foo").toAbsolutePath().toString(), Uris.getAbsolutePath(relativePath).toString());
    }

    @Test
    public void testResolveToRoot() {
        String expectedPath = "file://" + root.getRoot().getAbsolutePath() + "/myfile.txt";
        String uri1 = "file:" + root.getRoot().getAbsolutePath() + "/myfile.txt";
        String uri2 = "file://" + root.getRoot().getAbsolutePath() + "/myfile.txt";
        String relativePath = "something/somethingelse/../somethingelse/./../../myfile.txt";
        String absolutePath =
                root.getRoot().getAbsolutePath() + "/something/somethingelse/../somethingelse/./../../myfile.txt";
        assertEquals(expectedPath, Uris.resolveToRoot(root.getRoot().toPath(), uri1).toString());
        assertEquals(expectedPath, Uris.resolveToRoot(root.getRoot().toPath(), uri2).toString());
        assertEquals(expectedPath, Uris.resolveToRoot(root.getRoot().toPath(), absolutePath).toString());
        assertEquals(expectedPath, Uris.resolveToRoot(root.getRoot().toPath(), relativePath).toString());
    }

    @Test
    public void testResolveToRoot_nonAbsoluteUri() {
        expectedException.expect(IllegalArgumentException.class);
        expectedException.expectMessage("absoluteRootPath must be absolute");
        Uris.resolveToRoot(Paths.get("foo"), "foo");
    }

}
