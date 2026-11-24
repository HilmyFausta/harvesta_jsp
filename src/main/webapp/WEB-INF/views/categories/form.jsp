<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>

<c:set var="isEdit" value="${not empty category}" />
<c:set var="title" value="${isEdit ? 'Edit Category' : 'Create Category'}" />

<ui:layout title="${title}" active="categories">
    <ui:header title="${title}" description="${isEdit ? 'Update category information.' : 'Add a new master category.'}">
        <a href="${pageContext.request.contextPath}/categories"
           class="inline-flex items-center text-sm font-medium text-zinc-600 hover:text-zinc-900 dark:text-zinc-300 dark:hover:text-white">
            ← Back
        </a>
    </ui:header>

    <div class="max-w-xl rounded-xl border border-zinc-200 bg-white p-6 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
        <form method="POST" action="${pageContext.request.contextPath}/categories${isEdit ? '/' += category.id : ''}" class="space-y-6">
            <c:if test="${isEdit}">
                <input type="hidden" name="_method" value="PUT" />
            </c:if>

            <div>
                <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="name">
                    Name <span class="text-red-500">*</span>
                </label>
                <input id="name" name="name" type="text" required value="${h:e(category.name)}" placeholder="e.g. Fruit, Timber"
                       class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10" />
            </div>

            <div>
                <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="description">Description</label>
                <textarea id="description" name="description" rows="3" placeholder="Optional notes about this category"
                          class="w-full border block appearance-none text-sm rounded-lg py-2 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10">${h:e(category.description)}</textarea>
            </div>

            <div class="flex items-center justify-end gap-3 pt-4 border-t border-zinc-100 dark:border-zinc-800">
                <a href="${pageContext.request.contextPath}/categories"
                   class="px-4 py-2 text-sm font-medium text-zinc-700 dark:text-zinc-300 hover:text-zinc-900">Cancel</a>
                <button type="submit"
                        class="px-5 py-2.5 rounded-lg bg-[var(--color-accent)] text-white text-sm font-semibold hover:opacity-90 shadow-sm">
                    ${isEdit ? 'Save changes' : 'Create category'}
                </button>
            </div>
        </form>
    </div>
</ui:layout>
