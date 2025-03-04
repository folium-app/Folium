/*
    Copyright 2016-2024 melonDS team

    This file is part of melonDS.

    melonDS is free software: you can redistribute it and/or modify it under
    the terms of the GNU General Public License as published by the Free
    Software Foundation, either version 3 of the License, or (at your option)
    any later version.

    melonDS is distributed in the hope that it will be useful, but WITHOUT ANY
    WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with melonDS. If not, see http://www.gnu.org/licenses/.
*/

#ifndef VERSION_H
#define VERSION_H

#define MELONDS_URL            "${melonDS_HOMEPAGE_URL}"

#define MELONDS_VERSION_BASE   "1.0.0-1"
#define MELONDS_VERSION_SUFFIX "${MELONDS_VERSION_SUFFIX}"
#define MELONDS_VERSION        MELONDS_VERSION_BASE MELONDS_VERSION_SUFFIX

#ifdef MELONDS_EMBED_BUILD_INFO
#define MELONDS_GIT_BRANCH       "${MELONDS_GIT_BRANCH}"
#define MELONDS_GIT_HASH         "${MELONDS_GIT_HASH}"
#define MELONDS_BUILD_PROVIDER   "${MELONDS_BUILD_PROVIDER}"
#endif

#endif // VERSION_H

