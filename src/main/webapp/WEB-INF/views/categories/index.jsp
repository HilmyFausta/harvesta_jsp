<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>

<ui:layout title="Categories" active="categories">
    <ui:header title="Categories" description="High-level groupings for tree types (fruit, timber, ornamental, spice).">
        <c:if test="${isAdmin}">
            <a href="${pageContext.request.contextPath}/categories/create"
               class="relative inline-flex items-center font-medium justify-center whitespace-nowrap h-10 text-sm rounded-lg gap-2 ps-3 pe-4 bg-[var(--color-accent)] hover:bg-[color-mix(in_oklab,_var(--color-accent),_transparent_10%)] text-[var(--color-accent-foreground)] border border-black/10 dark:border-0 shadow-[inset_0px_1px_--theme(--color-white/.2)]">
                ${h:icon('plus')}
                <span>Add category</span>
            </a>
        </c:if>
    </ui:header>

    <div class="rounded-xl border border-zinc-200 bg-white p-5 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
        <c:choose>
            <c:when test="${not empty categories}">
                <div class="overflow-x-auto">
                    <table class="[:where(&)]:min-w-full table-fixed border-separate border-spacing-0 isolate text-zinc-800 dark:text-zinc-200 whitespace-nowrap" data-flux-table>
                        <thead>
                            <tr class="text-xs font-semibold uppercase tracking-wider text-zinc-500 border-b border-zinc-200 dark:border-zinc-700">
                                <th class="py-3 px-3 text-start">Category</th>
                                <th class="py-3 px-3 text-start">Description</th>
                                <th class="py-3 px-3 text-start">Tree Types</th>
                                <c:if test="${isAdmin}">
                                    <th class="py-3 px-3 text-end">Actions</th>
                                </c:if>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-sm">
                            <c:forEach var="c" items="${categories}">
                                <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50 transition-colors">
                                    <td class="py-3 px-3 font-semibold text-zinc-900 dark:text-white">${h:e(c.name)}</td>
                                    <td class="py-3 px-3 text-zinc-600 dark:text-zinc-400 max-w-md truncate">${empty c.description ? '—' : h:e(c.description)}</td>
                                    <td class="py-3 px-3">
                                        <a href="${pageContext.request.contextPath}/tree-types?category_id=${c.id}" class="text-[var(--color-accent-content)] hover:underline font-medium">
                                            ${c.type_count} ${c.type_count == 1 ? 'type' : 'types'}
                                        </a>
                                    </td>
                                    <c:if test="${isAdmin}">
                                        <td class="py-3 px-3 text-end">
                                            <div class="inline-flex items-center gap-2">
                                                <a href="${pageContext.request.contextPath}/categories/${c.id}/edit" class="p-1 text-zinc-500 hover:text-zinc-800 dark:hover:text-white" title="Edit category">
                                                    ${h:icon('pencil')}
                                                </a>
                                                <form method="POST" action="${pageContext.request.contextPath}/categories/${c.id}/delete" onsubmit="return confirm('Are you sure you want to delete this category?');" class="inline">
                                                    <button type="submit" class="p-1 text-red-500 hover:text-red-700 cursor-pointer" title="Delete category">
                                                        ${h:icon('trash')}
                                                    </button>
                                                </form>
                                            </div>
                                        </td>
                                    </c:if>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:when>
            <c:otherwise>
                <ui:empty title="No categories found" description="Add master categories to organize your tree types.">
                    <c:if test="${isAdmin}">
                        <a href="${pageContext.request.contextPath}/categories/create" class="inline-flex items-center px-4 py-2 rounded-lg bg-[var(--color-accent)] text-white text-sm font-medium">Add category</a>
                    </c:if>
                </ui:empty>
            </c:otherwise>
        </c:choose>
    </div>
</ui:layout>
