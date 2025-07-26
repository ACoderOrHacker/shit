import { defineConfig } from 'vitepress'

export default defineConfig({
  head: [
    ["link", { rel: "icon", href: `/shit/logo.ico` }],
  ],
  base: '/shit/',
  title: "Shit",
  description: "A powerful and modern terminal",
  themeConfig: {
    logo: '/logo.png',
    siteTitle: 'Shit',
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Downloads', link: '/downloads/' }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/ACoderOrHacker/shit' }
    ]
  }
})
