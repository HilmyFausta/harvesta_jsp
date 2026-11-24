<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>

<ui:layout title="Tree Types" active="tree-types">
    <ui:header title="Tree Types" description="Species and varieties managed in the orchard, grouped by category.">
        <c:if test="${isAdmin}">
            <a href="${pageContext.request.contextPath}/tree-types/create"
               class="relative inline-flex items-center font-medium justify-center whitespace-nowrap h-10 text-sm rounded-lg gap-2 ps-3 pe-4 bg-[var(--color-accent)] hover:bg-[color-mix(in_oklab,_var(--color-accent),_transparent_10%)] text-[var(--color-accent-foreground)] border border-black/10 dark:border-0 shadow-[inset_0px_1px_--theme(--color-white/.2)]">
                ${h:icon('plus')}
                <span>Add tree type</span>
            </a>
        </c:if>
    </ui:header>

    <!-- Filters -->
    <div class="mb-6 rounded-xl border border-zinc-200 bg-white p-4 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
        <form method="GET" action="${pageContext.request.contextPath}/tree-types" class="grid gap-4 sm:grid-cols-3">
            <div>
                <label class="block text-xs font-semibold uppercase tracking-wider text-zinc-500 mb-1">Search</label>
                <input type="text" name="search" value="${h:e(search)}" placeholder="Name or scientific name..."
                       class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10" />
            </div>

            <div>
                <label class="block text-xs font-semibold uppercase tracking-wider text-zinc-500 mb-1">Category</label>
                <select name="category_id" class="w-full block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10">
                    <option value="">All categories</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.id}" ${cat.id == selectedCategoryId ? 'selected' : ''}>${h:e(cat.name)}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="flex items-end gap-2">
                <button type="submit" class="w-full h-10 text-sm font-medium rounded-lg bg-[var(--color-accent)] text-white hover:opacity-90">Filter</button>
                <a href="${pageContext.request.contextPath}/tree-types" class="h-10 px-3 inline-flex items-center text-sm font-medium rounded-lg border border-zinc-200 dark:border-zinc-700 text-zinc-600 dark:text-zinc-300 hover:bg-zinc-50 dark:hover:bg-zinc-800">Reset</a>
            </div>
        </form>
    </div>

    <!-- Tree Types Table Card -->
    <div class="rounded-xl border border-zinc-200 bg-white p-5 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
        <c:choose>
            <c:when test="${not empty treeTypes}">
                <div class="overflow-x-auto">
                    <table class="[:where(&)]:min-w-full table-fixed border-separate border-spacing-0 isolate text-zinc-800 dark:text-zinc-200 whitespace-nowrap" data-flux-table>
                        <thead>
                            <tr class="text-xs font-semibold uppercase tracking-wider text-zinc-500 border-b border-zinc-200 dark:border-zinc-700">
                                <th class="py-3 px-3 text-start">Name</th>
                                <th class="py-3 px-3 text-start">Category</th>
                                <th class="py-3 px-3 text-start">Scientific Name</th>
                                <th class="py-3 px-3 text-start">Planted Trees</th>
                                <c:if test="${isAdmin}">
                                    <th class="py-3 px-3 text-end">Actions</th>
                                </c:if>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-sm">
                            <c:forEach var="tt" items="${treeTypes}">
                                <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50 transition-colors">
                                    <td class="py-3 px-3 font-semibold text-zinc-900 dark:text-white">${h:e(tt.name)}</td>
                                    <td class="py-3 px-3">
                                        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-zinc-100 text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
                                            ${h:e(tt.category_name)}
                                        </span>
                                    </td>
                                    <td class="py-3 px-3 italic text-zinc-500 dark:text-zinc-400">${empty tt.scientific_name ? '—' : h:e(tt.scientific_name)}</td>
                                    <td class="py-3 px-3">
                                        <a href="${pageContext.request.contextPath}/trees?tree_type_id=${tt.id}" class="text-[var(--color-accent-content)] hover:underline font-medium">
                                            ${tt.tree_count} ${tt.tree_count == 1 ? 'tree' : 'trees'}
                                        </a>
                                    </td>
                                    <c:if test="${isAdmin}">
                                        <td class="py-3 px-3 text-end">
                                            <div class="inline-flex items-center gap-2">
                                                <a href="${pageContext.request.contextPath}/tree-types/${tt.id}/edit" class="p-1 text-zinc-500 hover:text-zinc-800 dark:hover:text-white" title="Edit tree type">
                                                    ${h:icon('pencil')}
                                                </a>
                                                <form method="POST" action="${pageContext.request.contextPath}/tree-types/${tt.id}/delete" onsubmit="return confirm('Are you sure you want to delete this tree type?');" class="inline">
                                                    <button type="submit" class="p-1 text-red-500 hover:text-red-700 cursor-pointer" title="Delete tree type">
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
                <ui:empty title="No tree types found" description="Add tree types to categorize your plantings.">
                    <c:if test="${isAdmin}">
                        <a href="${pageContext.request.contextPath}/tree-types/create" class="inline-flex items-center px-4 py-2 rounded-lg bg-[var(--color-accent)] text-white text-sm font-medium">Add tree type</a>
                    </c:if>
                </ui:empty>
            </c:otherwise>
        </c:choose>
    </div>
</ui:layout>
