<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ attribute name="title" required="true" %>
<%@ attribute name="active" required="false" %>
<%@ attribute name="charts" type="java.lang.Boolean" required="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>${h:e(title)} - HARVESTA</title>

    <link rel="icon" href="${ctx}/favicon.ico" sizes="32x32">
    <link rel="icon" href="${ctx}/favicon.svg" type="image/svg+xml">
    <link rel="apple-touch-icon" href="${ctx}/apple-touch-icon.png">

    <style>
    @font-face {
      font-family: "Inter";
      font-style: normal;
      font-weight: 400;
      font-display: swap;
      src: url("${ctx}/build/assets/inter-400-normal-C38fXH4l.woff2") format("woff2");
    }
    @font-face {
      font-family: "Inter";
      font-style: normal;
      font-weight: 500;
      font-display: swap;
      src: url("${ctx}/build/assets/inter-500-normal-Cerq10X2.woff2") format("woff2");
    }
    @font-face {
      font-family: "Inter";
      font-style: normal;
      font-weight: 600;
      font-display: swap;
      src: url("${ctx}/build/assets/inter-600-normal-LgqL8muc.woff2") format("woff2");
    }
    @font-face {
      font-family: "Inter";
      font-style: normal;
      font-weight: 700;
      font-display: swap;
      src: url("${ctx}/build/assets/inter-700-normal-Yt3aPRUw.woff2") format("woff2");
    }
    :root {
      --font-inter: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      --color-accent: #2F7D4F;
      --color-accent-foreground: #FFFFFF;
      --color-accent-content: #2F7D4F;
    }
    body {
      font-family: var(--font-inter);
    }
    .account-menu {
      position: relative;
    }
    .account-menu__trigger {
      list-style: none;
    }
    .account-menu__trigger::-webkit-details-marker {
      display: none;
    }
    .account-menu__panel {
      position: absolute;
      inset-inline: 0;
      bottom: calc(100% + .5rem);
      z-index: 50;
    }
    .account-menu[open] .account-menu__chevron {
      transform: rotate(180deg);
    }
    </style>
    <link rel="stylesheet" href="${ctx}/build/assets/app-C1XXSIRJ.css" />
    <script>
        window.Flux = {
            applyAppearance(appearance) {
                if (appearance === 'dark' || (appearance === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
                    document.documentElement.classList.add('dark');
                } else {
                    document.documentElement.classList.remove('dark');
                }
            }
        };
        window.Flux.applyAppearance(localStorage.getItem('flux.appearance') || 'system');

        function toggleSidebar() {
            var sb = document.getElementById('app-sidebar');
            var bd = document.getElementById('mobile-backdrop');
            if (sb && bd) {
                var isHidden = sb.classList.contains('max-lg:-translate-x-full');
                if (isHidden) {
                    sb.classList.remove('max-lg:-translate-x-full');
                    bd.classList.remove('hidden');
                } else {
                    sb.classList.add('max-lg:-translate-x-full');
                    bd.classList.add('hidden');
                }
            }
        }

        document.addEventListener('click', function (event) {
            var menu = document.getElementById('account-menu');
            if (menu && menu.open && !menu.contains(event.target)) {
                menu.open = false;
            }
        });

        document.addEventListener('keydown', function (event) {
            var menu = document.getElementById('account-menu');
            if (menu && event.key === 'Escape') {
                menu.open = false;
            }
        });
    </script>
    <c:if test="${charts}">
        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.4/dist/chart.umd.min.js"></script>
    </c:if>
</head>
<body class="min-h-screen bg-cream text-ink dark:bg-zinc-800 dark:text-white">

    <!-- Mobile Backdrop -->
    <div id="mobile-backdrop" onclick="toggleSidebar()" class="z-20 fixed inset-0 bg-black/20 hidden lg:hidden"></div>

    <!-- Sidebar -->
    <ui-sidebar id="app-sidebar"
        class="[grid-area:sidebar] z-30 flex flex-col gap-4 [:where(&)]:w-64 p-4 max-lg:fixed max-lg:top-0 max-lg:bottom-0 max-lg:start-0 max-lg:-translate-x-full max-lg:transition-transform max-lg:duration-200 max-h-dvh overflow-y-auto overscroll-contain border-e border-zinc-200 bg-white dark:border-zinc-700 dark:bg-zinc-900"
        data-flux-sidebar>
        
        <!-- Brand Header -->
        <div class="flex items-center justify-between gap-2 min-h-10" data-flux-sidebar-header>
            <a href="${ctx}/dashboard" class="h-10 min-w-0 flex items-center px-2 gap-2" data-flux-sidebar-brand>
                <div class="flex aspect-square size-8 items-center justify-center rounded-md bg-accent-content text-accent-foreground">
                    ${h:icon('leaf')}
                </div>
                <div class="min-w-0 text-sm font-semibold tracking-wide text-zinc-800 dark:text-zinc-100">HARVESTA</div>
            </a>
            <button type="button" onclick="toggleSidebar()" class="w-8 h-8 flex items-center justify-center rounded-lg text-zinc-500 hover:bg-zinc-100 lg:hidden">
                <svg class="size-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
            </button>
        </div>

        <!-- Navigation items -->
        <nav class="flex-1 flex flex-col gap-6" data-flux-nav>
            <div class="flex flex-col gap-1">
                <a href="${ctx}/dashboard" class="h-9 relative flex items-center gap-3 rounded-lg py-0 px-3 text-sm font-medium transition-colors ${active == 'dashboard' ? 'bg-zinc-800/5 text-(--color-accent-content) dark:bg-white/[7%] font-semibold' : 'text-zinc-600 dark:text-white/80 hover:bg-zinc-800/5 hover:text-zinc-900'}">
                    ${h:icon('dashboard')}
                    <span>Dashboard</span>
                </a>
                <a href="${ctx}/trees" class="h-9 relative flex items-center gap-3 rounded-lg py-0 px-3 text-sm font-medium transition-colors ${active == 'trees' ? 'bg-zinc-800/5 text-(--color-accent-content) dark:bg-white/[7%] font-semibold' : 'text-zinc-600 dark:text-white/80 hover:bg-zinc-800/5 hover:text-zinc-900'}">
                    ${h:icon('tree')}
                    <span>Trees</span>
                </a>
                <a href="${ctx}/care-logs" class="h-9 relative flex items-center gap-3 rounded-lg py-0 px-3 text-sm font-medium transition-colors ${active == 'care-logs' ? 'bg-zinc-800/5 text-(--color-accent-content) dark:bg-white/[7%] font-semibold' : 'text-zinc-600 dark:text-white/80 hover:bg-zinc-800/5 hover:text-zinc-900'}">
                    ${h:icon('care-logs')}
                    <span>Care Logs</span>
                </a>
                <a href="${ctx}/harvests" class="h-9 relative flex items-center gap-3 rounded-lg py-0 px-3 text-sm font-medium transition-colors ${active == 'harvests' ? 'bg-zinc-800/5 text-(--color-accent-content) dark:bg-white/[7%] font-semibold' : 'text-zinc-600 dark:text-white/80 hover:bg-zinc-800/5 hover:text-zinc-900'}">
                    ${h:icon('harvests')}
                    <span>Harvests</span>
                </a>
            </div>

            <!-- Master Data Group -->
            <div class="flex flex-col gap-1">
                <div class="px-3 text-xs font-semibold uppercase tracking-wider text-zinc-400 dark:text-zinc-500">Master Data</div>
                <a href="${ctx}/categories" class="h-9 relative flex items-center gap-3 rounded-lg py-0 px-3 text-sm font-medium transition-colors ${active == 'categories' ? 'bg-zinc-800/5 text-(--color-accent-content) dark:bg-white/[7%] font-semibold' : 'text-zinc-600 dark:text-white/80 hover:bg-zinc-800/5 hover:text-zinc-900'}">
                    ${h:icon('categories')}
                    <span>Categories</span>
                </a>
                <a href="${ctx}/tree-types" class="h-9 relative flex items-center gap-3 rounded-lg py-0 px-3 text-sm font-medium transition-colors ${active == 'tree-types' ? 'bg-zinc-800/5 text-(--color-accent-content) dark:bg-white/[7%] font-semibold' : 'text-zinc-600 dark:text-white/80 hover:bg-zinc-800/5 hover:text-zinc-900'}">
                    ${h:icon('tree-types')}
                    <span>Tree Types</span>
                </a>
                <a href="${ctx}/blocks" class="h-9 relative flex items-center gap-3 rounded-lg py-0 px-3 text-sm font-medium transition-colors ${active == 'blocks' ? 'bg-zinc-800/5 text-(--color-accent-content) dark:bg-white/[7%] font-semibold' : 'text-zinc-600 dark:text-white/80 hover:bg-zinc-800/5 hover:text-zinc-900'}">
                    ${h:icon('blocks')}
                    <span>Blocks</span>
                </a>
            </div>

            <!-- Admin Groups -->
            <c:if test="${isAdmin}">
                <div class="flex flex-col gap-1">
                    <div class="px-3 text-xs font-semibold uppercase tracking-wider text-zinc-400 dark:text-zinc-500">Finance</div>
                    <a href="${ctx}/expenses" class="h-9 relative flex items-center gap-3 rounded-lg py-0 px-3 text-sm font-medium transition-colors ${active == 'expenses' ? 'bg-zinc-800/5 text-(--color-accent-content) dark:bg-white/[7%] font-semibold' : 'text-zinc-600 dark:text-white/80 hover:bg-zinc-800/5 hover:text-zinc-900'}">
                        ${h:icon('expenses')}
                        <span>Expenses</span>
                    </a>
                    <a href="${ctx}/sales" class="h-9 relative flex items-center gap-3 rounded-lg py-0 px-3 text-sm font-medium transition-colors ${active == 'sales' ? 'bg-zinc-800/5 text-(--color-accent-content) dark:bg-white/[7%] font-semibold' : 'text-zinc-600 dark:text-white/80 hover:bg-zinc-800/5 hover:text-zinc-900'}">
                        ${h:icon('sales')}
                        <span>Sales</span>
                    </a>
                </div>

                <div class="flex flex-col gap-1">
                    <div class="px-3 text-xs font-semibold uppercase tracking-wider text-zinc-400 dark:text-zinc-500">Administration</div>
                    <a href="${ctx}/reports" class="h-9 relative flex items-center gap-3 rounded-lg py-0 px-3 text-sm font-medium transition-colors ${active == 'reports' ? 'bg-zinc-800/5 text-(--color-accent-content) dark:bg-white/[7%] font-semibold' : 'text-zinc-600 dark:text-white/80 hover:bg-zinc-800/5 hover:text-zinc-900'}">
                        ${h:icon('reports')}
                        <span>Reports</span>
                    </a>
                    <a href="${ctx}/users" class="h-9 relative flex items-center gap-3 rounded-lg py-0 px-3 text-sm font-medium transition-colors ${active == 'users' ? 'bg-zinc-800/5 text-(--color-accent-content) dark:bg-white/[7%] font-semibold' : 'text-zinc-600 dark:text-white/80 hover:bg-zinc-800/5 hover:text-zinc-900'}">
                        ${h:icon('users')}
                        <span>Users</span>
                    </a>
                </div>
            </c:if>
        </nav>

        <!-- Sidebar Footer / User Profile -->
        <div class="pt-4 border-t border-zinc-200 dark:border-zinc-700 flex flex-col gap-2">
            <details id="account-menu" class="account-menu">
                <summary class="account-menu__trigger flex items-center gap-2 rounded-lg px-2 py-2 cursor-pointer hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                    <span class="inline-flex size-8 shrink-0 items-center justify-center rounded-md border border-zinc-200 bg-zinc-100 text-xs font-semibold text-zinc-700 dark:border-zinc-700 dark:bg-zinc-800 dark:text-zinc-200">
                        ${h:initials(user.name)}
                    </span>
                    <span class="min-w-0 flex-1 text-left">
                        <span class="block truncate text-xs font-medium text-zinc-800 dark:text-zinc-100">${h:e(user.name)}</span>
                        <span class="block truncate text-[11px] text-zinc-500 dark:text-zinc-400">${h:e(user.email)}</span>
                    </span>
                    <svg class="account-menu__chevron size-4 shrink-0 text-zinc-400 transition-transform" viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true">
                        <path d="m7 10 5 5 5-5" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                </summary>
                <div class="account-menu__panel overflow-hidden rounded-lg border border-zinc-200 bg-white shadow-lg dark:border-zinc-700 dark:bg-zinc-900">
                    <div class="flex items-center gap-3 border-b border-zinc-200 px-3 py-2.5 dark:border-zinc-700">
                        <span class="inline-flex size-9 shrink-0 items-center justify-center rounded-md border border-zinc-200 bg-zinc-100 text-sm font-semibold text-zinc-700 dark:border-zinc-700 dark:bg-zinc-800 dark:text-zinc-200">
                            ${h:initials(user.name)}
                        </span>
                        <span class="min-w-0">
                            <span class="block truncate text-sm font-medium text-zinc-800 dark:text-zinc-100">${h:e(user.name)}</span>
                            <span class="block truncate text-xs text-zinc-500 dark:text-zinc-400">${h:e(user.email)}</span>
                        </span>
                    </div>
                    <div class="p-1">
                        <a href="${ctx}/settings/profile" class="flex items-center gap-2 rounded-md px-2 py-2 text-sm text-zinc-700 hover:bg-zinc-100 dark:text-zinc-200 dark:hover:bg-zinc-800">
                            <svg class="size-4 text-zinc-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true">
                                <circle cx="12" cy="8" r="4" stroke-width="1.8"/>
                                <path d="M5 21a7 7 0 0 1 14 0" stroke-width="1.8" stroke-linecap="round"/>
                            </svg>
                            <span>Profile</span>
                        </a>
                        <a href="${ctx}/settings/appearance" class="flex items-center gap-2 rounded-md px-2 py-2 text-sm text-zinc-700 hover:bg-zinc-100 dark:text-zinc-200 dark:hover:bg-zinc-800">
                            <svg class="size-4 text-zinc-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true">
                                <circle cx="12" cy="12" r="9" stroke-width="1.8"/>
                                <path d="M12 3v18a9 9 0 0 0 0-18Z" stroke-width="1.8"/>
                            </svg>
                            <span>Theme</span>
                        </a>
                        <form method="POST" action="${ctx}/logout">
                            <button type="submit" class="flex w-full items-center gap-2 rounded-md px-2 py-2 text-left text-sm text-red-600 hover:bg-red-50 dark:text-red-400 dark:hover:bg-red-950/30">
                                <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true">
                                    <path d="M10 17l5-5-5-5M15 12H3m9-9h6a3 3 0 0 1 3 3v12a3 3 0 0 1-3 3h-6" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                                </svg>
                                <span>Log out</span>
                            </button>
                        </form>
                    </div>
                </div>
            </details>
        </div>
    </ui-sidebar>

    <!-- Mobile Top Header Bar -->
    <header class="[grid-area:header] z-10 min-h-14 flex items-center justify-between px-4 border-b border-zinc-200 dark:border-zinc-700 bg-white dark:bg-zinc-900 lg:hidden" data-flux-header>
        <button type="button" onclick="toggleSidebar()" class="w-10 h-10 flex items-center justify-center rounded-lg text-zinc-600 hover:bg-zinc-100 dark:text-zinc-300">
            <svg class="size-6" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/></svg>
        </button>
        <div class="flex items-center gap-2">
            <div class="flex aspect-square size-7 items-center justify-center rounded-md bg-accent-content text-accent-foreground">
                ${h:icon('leaf')}
            </div>
            <span class="font-semibold text-sm tracking-wide text-zinc-800 dark:text-zinc-100">HARVESTA</span>
        </div>
        <div class="w-10"></div>
    </header>

    <!-- Main Content Area -->
    <div class="[grid-area:main] p-6 lg:p-8 [[data-flux-container]_&]:px-0" data-flux-main>
        
        <!-- Flash Alert Messages -->
        <c:if test="${not empty flashSuccess}">
            <div class="mb-6 rounded-xl border border-green-200 bg-green-50 p-4 dark:border-green-900/50 dark:bg-green-950/40">
                <div class="flex items-center gap-3">
                    <svg class="size-5 text-green-600 dark:text-green-400 shrink-0" viewBox="0 0 20 20" fill="currentColor">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.857-9.809a.75.75 0 00-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 10-1.06 1.061l2.5 2.5a.75.75 0 001.137-.089l4-5.5z" clip-rule="evenodd" />
                    </svg>
                    <p class="text-sm font-medium text-green-800 dark:text-green-200">${h:e(flashSuccess)}</p>
                </div>
            </div>
        </c:if>

        <c:if test="${not empty flashError}">
            <div class="mb-6 rounded-xl border border-red-200 bg-red-50 p-4 dark:border-red-900/50 dark:bg-red-950/40">
                <div class="flex items-center gap-3">
                    <svg class="size-5 text-red-600 dark:text-red-400 shrink-0" viewBox="0 0 20 20" fill="currentColor">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.28 7.22a.75.75 0 00-1.06 1.06L8.94 10l-1.72 1.72a.75.75 0 101.06 1.06L10 11.06l1.72 1.72a.75.75 0 101.06-1.06L11.06 10l1.72-1.72a.75.75 0 00-1.06-1.06L10 8.94 8.28 7.22z" clip-rule="evenodd" />
                    </svg>
                    <p class="text-sm font-medium text-red-800 dark:text-red-200">${h:e(flashError)}</p>
                </div>
            </div>
        </c:if>

        <jsp:doBody />
    </div>

</body>
</html>
