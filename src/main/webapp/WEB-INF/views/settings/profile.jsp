<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>

<ui:layout title="Profile settings" active="settings">
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
                   class="h-10 lg:h-8 relative flex items-center gap-3 rounded-lg py-0 text-start w-full px-3 my-px text-[var(--color-accent-content)] bg-zinc-800/[4%] dark:bg-white/[7%] font-semibold">
                    <div class="flex-1 text-sm leading-none whitespace-nowrap">Profile</div>
                </a>
                <a href="${pageContext.request.contextPath}/settings/security"
                   class="h-10 lg:h-8 relative flex items-center gap-3 rounded-lg py-0 text-start w-full px-3 my-px text-zinc-500 dark:text-white/80 hover:text-zinc-800 dark:hover:text-white hover:bg-zinc-800/[4%] dark:hover:bg-white/[7%]">
                    <div class="flex-1 text-sm font-medium leading-none whitespace-nowrap">Security</div>
                </a>
                <a href="${pageContext.request.contextPath}/settings/appearance"
                   class="h-10 lg:h-8 relative flex items-center gap-3 rounded-lg py-0 text-start w-full px-3 my-px text-zinc-500 dark:text-white/80 hover:text-zinc-800 dark:hover:text-white hover:bg-zinc-800/[4%] dark:hover:bg-white/[7%]">
                    <div class="flex-1 text-sm font-medium leading-none whitespace-nowrap">Appearance</div>
                </a>
            </nav>
        </div>

        <div class="border-0 bg-zinc-800/15 dark:bg-white/20 h-px w-full md:hidden my-4" role="none"></div>

        <!-- Form Area -->
        <div class="flex-1 self-stretch max-md:pt-6">
            <h2 class="font-medium text-zinc-800 dark:text-white text-base mb-1">Profile</h2>
            <div class="text-sm text-zinc-500 dark:text-white/70">Update your name and email address</div>

            <div class="mt-5 w-full max-w-lg">
                <c:if test="${not empty errors}">
                    <div class="mb-6 rounded-lg bg-red-50 p-4 border border-red-200 dark:bg-red-900/20 dark:border-red-800">
                        <ul class="list-disc list-inside text-sm text-red-700 dark:text-red-400">
                            <c:forEach var="err" items="${errors}">
                                <li>${err.value}</li>
                            </c:forEach>
                        </ul>
                    </div>
                </c:if>

                <form method="POST" action="${pageContext.request.contextPath}/settings/profile" class="my-6 w-full space-y-6">
                    <div>
                        <label class="inline-flex items-center text-sm font-medium text-zinc-800 dark:text-white mb-2">
                            Name
                        </label>
                        <input type="text" name="name" value="${h:e(user.name)}" required autocomplete="name" autofocus
                               class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10 ${not empty errors.name ? 'border-red-500' : ''}" />
                        <c:if test="${not empty errors.name}">
                            <p class="mt-1 text-xs text-red-500">${errors.name}</p>
                        </c:if>
                    </div>

                    <div>
                        <label class="inline-flex items-center text-sm font-medium text-zinc-800 dark:text-white mb-2">
                            Email
                        </label>
                        <input type="email" name="email" value="${h:e(user.email)}" required autocomplete="email"
                               class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10 ${not empty errors.email ? 'border-red-500' : ''}" />
                        <c:if test="${not empty errors.email}">
                            <p class="mt-1 text-xs text-red-500">${errors.email}</p>
                        </c:if>
                    </div>

                    <div class="flex items-center gap-4">
                        <button type="submit"
                                class="relative inline-flex items-center font-medium justify-center whitespace-nowrap h-10 text-sm rounded-lg px-6 bg-[var(--color-accent)] hover:bg-[color-mix(in_oklab,_var(--color-accent),_transparent_10%)] text-[var(--color-accent-foreground)] border border-black/10 dark:border-0 shadow-[inset_0px_1px_--theme(--color-white/.2)]">
                            Save
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</ui:layout>
