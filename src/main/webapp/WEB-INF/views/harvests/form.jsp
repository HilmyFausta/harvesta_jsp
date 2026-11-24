<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>

<c:set var="isEdit" value="${not empty harvest}" />
<c:set var="title" value="${isEdit ? 'Edit Harvest' : 'Log Harvest'}" />

<ui:layout title="${title}" active="harvests">
    <ui:header title="${title}" description="${isEdit ? 'Update harvest record.' : 'Record fruit and crop yields by tree, quantity, unit, and grade.'}">
        <a href="${pageContext.request.contextPath}/harvests"
           class="inline-flex items-center text-sm font-medium text-zinc-600 hover:text-zinc-900 dark:text-zinc-300 dark:hover:text-white">
            ← Back
        </a>
    </ui:header>

    <div class="max-w-2xl rounded-xl border border-zinc-200 bg-white p-6 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
        <form method="POST" action="${pageContext.request.contextPath}/harvests${isEdit ? '/' += harvest.id : ''}" class="space-y-6">
            <c:if test="${isEdit}">
                <input type="hidden" name="_method" value="PUT" />
            </c:if>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="tree_id">
                        Tree <span class="text-red-500">*</span>
                    </label>
                    <select id="tree_id" name="tree_id" required
                            class="w-full block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10">
                        <option value="">Select a tree</option>
                        <c:forEach var="t" items="${trees}">
                            <option value="${t.id}" ${(harvest.tree_id == t.id || selectedTreeId == t.id) ? 'selected' : ''}>${h:e(t.code)}</option>
                        </c:forEach>
                    </select>
                </div>

                <div>
                    <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="harvested_on">
                        Harvested on <span class="text-red-500">*</span>
                    </label>
                    <input id="harvested_on" name="harvested_on" type="date" required value="${harvest.harvested_on}"
                           class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10" />
                </div>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div>
                    <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="quantity">
                        Quantity <span class="text-red-500">*</span>
                    </label>
                    <input id="quantity" name="quantity" type="number" step="0.01" min="0.01" required value="${harvest.quantity}"
                           class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10" />
                </div>

                <div>
                    <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="unit">
                        Unit <span class="text-red-500">*</span>
                    </label>
                    <select id="unit" name="unit" required
                            class="w-full block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10">
                        <c:forEach var="entry" items="${harvestUnits}">
                            <option value="${entry.key}" ${harvest.unit == entry.key ? 'selected' : ''}>${entry.value}</option>
                        </c:forEach>
                    </select>
                </div>

                <div>
                    <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="grade">
                        Grade <span class="text-red-500">*</span>
                    </label>
                    <select id="grade" name="grade" required
                            class="w-full block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10">
                        <c:forEach var="entry" items="${harvestGrades}">
                            <option value="${entry.key}" ${harvest.grade == entry.key ? 'selected' : ''}>${entry.value}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div>
                <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="notes">Notes</label>
                <textarea id="notes" name="notes" rows="3" placeholder="Condition, ripeness, weather, etc."
                          class="w-full border block appearance-none text-sm rounded-lg py-2 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10">${h:e(harvest.notes)}</textarea>
            </div>

            <div class="flex items-center justify-end gap-3 pt-4 border-t border-zinc-100 dark:border-zinc-800">
                <a href="${pageContext.request.contextPath}/harvests"
                   class="px-4 py-2 text-sm font-medium text-zinc-700 dark:text-zinc-300 hover:text-zinc-900">Cancel</a>
                <button type="submit"
                        class="px-5 py-2.5 rounded-lg bg-[var(--color-accent)] text-white text-sm font-semibold hover:opacity-90 shadow-sm">
                    ${isEdit ? 'Save changes' : 'Log harvest'}
                </button>
            </div>
        </form>
    </div>
</ui:layout>
