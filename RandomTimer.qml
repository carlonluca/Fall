/**
 * GPLv3 License
 *
 * Copyright (c) 2021 Luca Carlon
 *
 * This file is part of Fall.
 *
 * Fall is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Fall is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Fall.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.0

Timer {
    interval: 0
    running: true
    repeat: false

    function restart(maxDelay) {
        interval = Math.random()*maxDelay
        start()
    }
}
