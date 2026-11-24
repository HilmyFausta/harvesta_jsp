<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>

<ui:auth-layout title="Register">
    <div class="flex flex-col gap-6">
        <div class="flex flex-col gap-1 text-center">
            <h1 class="text-xl font-semibold tracking-tight text-zinc-900 dark:text-white">Create an account</h1>
            <p class="text-sm text-zinc-500 dark:text-zinc-400">Enter your details below to create your account</p>
        </div>

        <c:if test="${not empty error}">
            <div class="rounded-lg border border-red-200 bg-red-50 p-3 text-sm font-medium text-red-600 dark:border-red-900/50 dark:bg-red-950/40 dark:text-red-400 text-center">
                ${h:e(error)}
            </div>
        </c:if>

        <form method="POST" action="${pageContext.request.contextPath}/register" class="flex flex-col gap-5">
            <div>
                <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="name">Name</label>
                <input id="name" name="name" type="text" required autofocus value="${h:e(name)}"
                       placeholder="Full name"
                       class="w-full border block appearance-none text-base sm:text-sm rounded-lg py-2 h-10 ps-3 pe-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 placeholder-zinc-400 shadow-xs border-zinc-200 border-b-zinc-300/80 dark:border-white/10 focus:outline-hidden focus:ring-2 focus:ring-(--color-accent)" />
            </div>

            <div>
                <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="email">Email address</label>
                <input id="email" name="email" type="email" required value="${h:e(email)}"
                       placeholder="email@example.com"
                       class="w-full border block appearance-none text-base sm:text-sm rounded-lg py-2 h-10 ps-3 pe-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 placeholder-zinc-400 shadow-xs border-zinc-200 border-b-zinc-300/80 dark:border-white/10 focus:outline-hidden focus:ring-2 focus:ring-(--color-accent)" />
            </div>

            <div>
                <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="password">Password</label>
                <input id="password" name="password" type="password" required placeholder="••••••••"
                       class="w-full border block appearance-none text-base sm:text-sm rounded-lg py-2 h-10 ps-3 pe-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 placeholder-zinc-400 shadow-xs border-zinc-200 border-b-zinc-300/80 dark:border-white/10 focus:outline-hidden focus:ring-2 focus:ring-(--color-accent)" />
            </div>

            <div>
                <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="password_confirmation">Confirm password</label>
                <input id="password_confirmation" name="password_confirmation" type="password" required placeholder="••••••••"
                       class="w-full border block appearance-none text-base sm:text-sm rounded-lg py-2 h-10 ps-3 pe-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 placeholder-zinc-400 shadow-xs border-zinc-200 border-b-zinc-300/80 dark:border-white/10 focus:outline-hidden focus:ring-2 focus:ring-(--color-accent)" />
            </div>

            <button type="submit"
                    class="relative inline-flex items-center font-medium justify-center whitespace-nowrap h-10 text-sm rounded-lg gap-2 ps-4 pe-4 bg-[var(--color-accent)] hover:bg-[color-mix(in_oklab,_var(--color-accent),_transparent_10%)] text-[var(--color-accent-foreground)] border border-black/10 dark:border-0 shadow-[inset_0px_1px_--theme(--color-white/.2)] w-full cursor-pointer">
                Create account
            </button>
        </form>

        <div class="space-x-1 text-sm text-center text-zinc-600 dark:text-zinc-400">
            <span>Already have an account?</span>
            <a href="${pageContext.request.contextPath}/login" class="font-medium underline hover:text-zinc-900 dark:hover:text-white text-[var(--color-accent-content)]">Log in</a>
        </div>
    </div>
</ui:auth-layout>
