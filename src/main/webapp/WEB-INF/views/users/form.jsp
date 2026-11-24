<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>

<ui:layout title="${isEdit ? 'Edit User' : 'Create User'}" active="users">
    <ui:header title="${isEdit ? 'Edit User' : 'Create User'}"
               description="${isEdit ? 'Update this person\'s account details and access.' : 'Add a new person to the farm team.'}" />

    <c:if test="${not empty errors}">
        <div class="mb-6 rounded-lg bg-red-50 p-4 border border-red-200 dark:bg-red-900/20 dark:border-red-800">
            <h3 class="text-sm font-medium text-red-800 dark:text-red-300">Please correct the following errors:</h3>
            <ul class="mt-2 list-disc list-inside text-sm text-red-700 dark:text-red-400">
                <c:forEach var="err" items="${errors}">
                    <li>${err.value}</li>
                </c:forEach>
            </ul>
        </div>
    </c:if>

    <form method="POST" action="${isEdit ? pageContext.request.contextPath.concat('/users/').concat(user.id).concat('/edit') : pageContext.request.contextPath.concat('/users/create')}" class="max-w-3xl space-y-6">
        <div class="rounded-xl border border-zinc-200 bg-white p-6 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
            <div class="grid gap-6 sm:grid-cols-2">
                <div>
                    <label class="block text-sm font-medium text-zinc-700 dark:text-zinc-300 mb-1">
                        Name <span class="text-red-500">*</span>
                    </label>
                    <input type="text" name="name" value="${h:e(user.name)}" required autocomplete="name"
                           class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10 ${not empty errors.name ? 'border-red-500' : ''}" />
                    <c:if test="${not empty errors.name}">
                        <p class="mt-1 text-xs text-red-500">${errors.name}</p>
                    </c:if>
                </div>

                <div>
                    <label class="block text-sm font-medium text-zinc-700 dark:text-zinc-300 mb-1">
                        Email <span class="text-red-500">*</span>
                    </label>
                    <input type="email" name="email" value="${h:e(user.email)}" required autocomplete="email"
                           class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10 ${not empty errors.email ? 'border-red-500' : ''}" />
                    <c:if test="${not empty errors.email}">
                        <p class="mt-1 text-xs text-red-500">${errors.email}</p>
                    </c:if>
                </div>

                <div>
                    <label class="block text-sm font-medium text-zinc-700 dark:text-zinc-300 mb-1">
                        Role <span class="text-red-500">*</span>
                    </label>
                    <c:choose>
                        <c:when test="${roleDisabled}">
                            <input type="hidden" name="role" value="admin" />
                            <select disabled class="w-full block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-zinc-100 dark:bg-zinc-800 text-zinc-500 border-zinc-200 dark:border-white/10 cursor-not-allowed">
                                <option value="admin" selected>Admin</option>
                            </select>
                            <p class="mt-1 text-xs text-zinc-500">The last admin must remain an admin.</p>
                        </c:when>
                        <c:otherwise>
                            <select name="role" class="w-full block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10 ${not empty errors.role ? 'border-red-500' : ''}">
                                <c:forEach var="entry" items="${roles}">
                                    <option value="${entry.key}" ${entry.key == user.role ? 'selected' : ''}>${entry.value}</option>
                                </c:forEach>
                            </select>
                            <c:if test="${not empty errors.role}">
                                <p class="mt-1 text-xs text-red-500">${errors.role}</p>
                            </c:if>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div>
                    <label class="block text-sm font-medium text-zinc-700 dark:text-zinc-300 mb-1">
                        ${isEdit ? 'New password' : 'Password'} <c:if test="${!isEdit}"><span class="text-red-500">*</span></c:if>
                    </label>
                    <input type="password" name="password" ${isEdit ? '' : 'required'} autocomplete="new-password"
                           class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10 ${not empty errors.password ? 'border-red-500' : ''}" />
                    <p class="mt-1 text-xs text-zinc-500">
                        ${isEdit ? 'Leave blank to keep the current password. (Minimum 8 characters if changing)' : 'Must be at least 8 characters.'}
                    </p>
                    <c:if test="${not empty errors.password}">
                        <p class="mt-1 text-xs text-red-500">${errors.password}</p>
                    </c:if>
                </div>
            </div>
        </div>

        <div class="flex flex-wrap items-center gap-3">
            <button type="submit"
                    class="relative inline-flex items-center font-medium justify-center whitespace-nowrap h-10 text-sm rounded-lg px-4 bg-[var(--color-accent)] hover:bg-[color-mix(in_oklab,_var(--color-accent),_transparent_10%)] text-[var(--color-accent-foreground)] border border-black/10 dark:border-0 shadow-[inset_0px_1px_--theme(--color-white/.2)]">
                ${isEdit ? 'Save changes' : 'Create user'}
            </button>
            <a href="${pageContext.request.contextPath}/users"
               class="inline-flex items-center h-10 px-4 text-sm font-medium rounded-lg text-zinc-600 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800">
                Cancel
            </a>
        </div>
    </form>
</ui:layout>
