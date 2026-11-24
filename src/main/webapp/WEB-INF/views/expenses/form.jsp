<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>

<c:set var="isEdit" value="${not empty expense}" />
<c:set var="title" value="${isEdit ? 'Edit Expense' : 'Record Expense'}" />

<ui:layout title="${title}" active="expenses">
    <ui:header title="${title}" description="${isEdit ? 'Update expense record.' : 'Track operational farm spending.'}">
        <a href="${pageContext.request.contextPath}/expenses"
           class="inline-flex items-center text-sm font-medium text-zinc-600 hover:text-zinc-900 dark:text-zinc-300 dark:hover:text-white">
            ← Back
        </a>
    </ui:header>

    <div class="max-w-xl rounded-xl border border-zinc-200 bg-white p-6 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
        <form method="POST" action="${pageContext.request.contextPath}/expenses${isEdit ? '/' += expense.id : ''}" class="space-y-6">
            <c:if test="${isEdit}">
                <input type="hidden" name="_method" value="PUT" />
            </c:if>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="category">
                        Category <span class="text-red-500">*</span>
                    </label>
                    <select id="category" name="category" required
                            class="w-full block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10">
                        <c:forEach var="entry" items="${categories}">
                            <option value="${entry.key}" ${expense.category == entry.key ? 'selected' : ''}>${entry.value}</option>
                        </c:forEach>
                    </select>
                </div>

                <div>
                    <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="block_id">
                        Block <span class="text-xs text-zinc-400 font-normal">(optional)</span>
                    </label>
                    <select id="block_id" name="block_id"
                            class="w-full block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10">
                        <option value="">General farm (no block)</option>
                        <c:forEach var="b" items="${blocks}">
                            <option value="${b.id}" ${expense.block_id == b.id ? 'selected' : ''}>${h:e(b.name)}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="amount">
                        Amount (IDR) <span class="text-red-500">*</span>
                    </label>
                    <input id="amount" name="amount" type="number" step="0.01" min="0.01" required value="${expense.amount}" placeholder="e.g. 500000"
                           class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10" />
                </div>

                <div>
                    <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="spent_on">
                        Spent on <span class="text-red-500">*</span>
                    </label>
                    <input id="spent_on" name="spent_on" type="date" required value="${expense.spent_on}"
                           class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10" />
                </div>
            </div>

            <div>
                <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="description">Description</label>
                <input id="description" name="description" type="text" value="${h:e(expense.description)}" placeholder="e.g. 5 bags of organic NPK fertilizer"
                       class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10" />
            </div>

            <div class="flex items-center justify-end gap-3 pt-4 border-t border-zinc-100 dark:border-zinc-800">
                <a href="${pageContext.request.contextPath}/expenses"
                   class="px-4 py-2 text-sm font-medium text-zinc-700 dark:text-zinc-300 hover:text-zinc-900">Cancel</a>
                <button type="submit"
                        class="px-5 py-2.5 rounded-lg bg-[var(--color-accent)] text-white text-sm font-semibold hover:opacity-90 shadow-sm">
                    ${isEdit ? 'Save changes' : 'Record expense'}
                </button>
            </div>
        </form>
    </div>
</ui:layout>
