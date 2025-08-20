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

        sidebar: [
            {
                text: "Getting Started",
                items: [
                    {
                        text: "Introduction",
                        link: "/getting-started/introduction.md"
                    },
                    {
                        text: "Quick Start",
                        link: "/getting-started/quick-start.md"
                    }
                ]
            },
            {
                text: "Basic Commands",
                items: [
                    {
                        text: "REPL",
                        link: "/basic/repl.md"
                    },
                    {
                        text: "Execute Commands",
                        link: "/basic/execute.md"
                    }
                ]
            },
            {
                text: "Package Management",
                items: [
                    {
                        text: "Create Packages",
                        link: "/package-management/create.md"
                    },
                    {
                        text: "Package Management in CLI",
                        link: "/package-management/package-management-in-cli.md"
                    }
                ]
            }
        ],

        socialLinks: [
            { icon: 'github', link: 'https://github.com/ACoderOrHacker/shit' }
        ]
    }
})
