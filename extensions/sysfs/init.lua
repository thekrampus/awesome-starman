------------------------------------------------------------
--- sysfs monitoring tools
--
-- @author Krampus &lt;tetramor.ph&gt;
-- @module sysfs
------------------------------------------------------------

-- patch package.path to load this package
local my_path = debug.getinfo(1).short_src:match('(.*/)')
local old_path = package.path
package.path = package.path .. ';' .. my_path .. "?.lua"

local sysfs = {}
sysfs.monitor = require('monitor')
sysfs.core_temp = require('core_temp')

package.path = old_path

return sysfs
