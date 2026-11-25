<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>

<ui:layout title="Appearance settings" active="settings">
    <div class="relative mb-6 w-full">
        <h1 class="font-medium text-zinc-800 dark:text-white text-2xl mb-1">Settings</h1>
        <div class="text-base text-zinc-500 dark:text-white/70 mb-6">Manage your profile and account settings</div>
        <div class="border-0 bg-zinc-800/10 dark:bg-white/10 h-px w-full" role="none"></div>
    </div>

    <div class="flex items-start max-md:flex-col">
        <!-- Settings Navlist -->
        <div class="me-10 w-full pb-4 md:w-[220px]">
            <nav aria-label="Settings" class="flex flex-col overflow-visible">
                <a href="${pageContext.request.contextPath}/settings/profile"
                   class="h-10 lg:h-8 relative flex items-center gap-3 rounded-lg py-0 text-start w-full px-3 my-px text-zinc-500 dark:text-white/80 hover:text-zinc-800 dark:hover:text-white hover:bg-zinc-800/[4%] dark:hover:bg-white/[7%]">
                    <div class="flex-1 text-sm font-medium leading-none whitespace-nowrap">Profile</div>
                </a>
                <a href="${pageContext.request.contextPath}/settings/security"
                   class="h-10 lg:h-8 relative flex items-center gap-3 rounded-lg py-0 text-start w-full px-3 my-px text-zinc-500 dark:text-white/80 hover:text-zinc-800 dark:hover:text-white hover:bg-zinc-800/[4%] dark:hover:bg-white/[7%]">
                    <div class="flex-1 text-sm font-medium leading-none whitespace-nowrap">Security</div>
                </a>
                <a href="${pageContext.request.contextPath}/settings/appearance"
                   class="h-10 lg:h-8 relative flex items-center gap-3 rounded-lg py-0 text-start w-full px-3 my-px text-[var(--color-accent-content)] bg-zinc-800/[4%] dark:bg-white/[7%] font-semibold">
                    <div class="flex-1 text-sm leading-none whitespace-nowrap">Appearance</div>
                </a>
            </nav>
        </div>

        <div class="border-0 bg-zinc-800/15 dark:bg-white/20 h-px w-full md:hidden my-4" role="none"></div>

        <!-- Content Area -->
        <div class="flex-1 self-stretch max-md:pt-6">
            <h2 class="font-medium text-zinc-800 dark:text-white text-base mb-1">Appearance</h2>
            <div class="text-sm text-zinc-500 dark:text-white/70">Update the appearance settings for your account</div>

            <div class="mt-5 w-full max-w-lg">
                <div class="flex p-1 rounded-lg bg-zinc-800/5 dark:bg-white/10 h-10 p-1" id="appearance-segmented">
                    <button type="button" onclick="setAppearance('light')" id="btn-light"
                            class="flex whitespace-nowrap flex-1 justify-center items-center gap-2 rounded-md text-sm font-medium text-zinc-600 hover:text-zinc-800 dark:hover:text-white dark:text-white/70 px-4 transition-colors">
                        ${h:icon('sun')}
                        <span>Light</span>
                    </button>
                    <button type="button" onclick="setAppearance('dark')" id="btn-dark"
                            class="flex whitespace-nowrap flex-1 justify-center items-center gap-2 rounded-md text-sm font-medium text-zinc-600 hover:text-zinc-800 dark:hover:text-white dark:text-white/70 px-4 transition-colors">
                        ${h:icon('moon')}
                        <span>Dark</span>
                    </button>
                    <button type="button" onclick="setAppearance('system')" id="btn-system"
                            class="flex whitespace-nowrap flex-1 justify-center items-center gap-2 rounded-md text-sm font-medium text-zinc-600 hover:text-zinc-800 dark:hover:text-white dark:text-white/70 px-4 transition-colors">
                        ${h:icon('computer-desktop')}
                        <span>System</span>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
        function setAppearance(theme) {
            localStorage.setItem('flux.appearance', theme);
            if (window.Flux && window.Flux.applyAppearance) {
                window.Flux.applyAppearance(theme);
            }
            updateActiveSegment(theme);
        }

        function updateActiveSegment(theme) {
            ['light', 'dark', 'system'].forEach(t => {
                const btn = document.getElementById('btn-' + t);
                if (btn) {
                    if (t === theme) {
                        btn.className = "flex whitespace-nowrap flex-1 justify-center items-center gap-2 rounded-md text-sm font-medium text-zinc-800 dark:text-white bg-white dark:bg-white/20 shadow-xs px-4";
                    } else {
                        btn.className = "flex whitespace-nowrap flex-1 justify-center items-center gap-2 rounded-md text-sm font-medium text-zinc-600 hover:text-zinc-800 dark:hover:text-white dark:text-white/70 px-4";
                    }
                }
            });
        }

        document.addEventListener('DOMContentLoaded', () => {
            const current = localStorage.getItem('flux.appearance') || 'light';
            updateActiveSegment(current);
        });
    </script>
</ui:layout>
