-- Aug 13 Thursday, 2015
-- ...

function catch(what)
   return what[1]
end

function try(what)
   status, result = pcall(what[1])
   if not status then
      what[2](result)
   end
   return result
end

-- usage demo:
try {
   function()
      error('oops')
   end,

   catch {
      function(error)
         print('caught error: ' .. error)
      end
   }
}
