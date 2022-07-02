import { useEffect, useState } from 'react'
import logo from './logo.svg'

export default function () {
  const [dark, setDarkMode] = useState(true)
  useEffect(() => {
    if (dark || window.matchMedia('(prefers-color-scheme: dark)').matches) {
      document.documentElement.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
    }

  }, [dark])

  return (
    <>
      <button className='px-4 py-1 text-sm text-purple-600 font-semibold rounded-full border border-purple-200 hover:text-white hover:bg-purple-600 hover:border-transparent focus:outline-none focus:ring-2 focus:ring-purple-600 focus:ring-offset-2'
        onClick={() => setDarkMode(!dark)}>{dark ? 'Dark' : 'Light'}</button>
      <div className="dark:bg-black bg-white p-6 max-w-sm mx-auto rounded-xl shadow-lg flex items-center space-x-4">
        <div className="shrink-0">
          <img className="h-12 w-12" src={logo} alt="ChitChat Logo" />
        </div>
        <div>
          <div className="text-xl font-medium text-black dark:text-white">ChitChat</div>
          <p className="text-slate-500 dark:text-slate-100">You have a new message!</p>
        </div>
      </div>
      <div className='container mx-auto px-4 p-3 my-3 dark:bg-blue-900 '>
        <p className='dark:text-slate-100 text-slate-800'>this is a container description</p>

      </div>
    </>
  )
}

