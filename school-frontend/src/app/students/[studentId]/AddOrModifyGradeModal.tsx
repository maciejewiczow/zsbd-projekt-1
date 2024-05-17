'use client';

import { Button, Form, FormInstance, Modal, Select, Slider } from 'antd';
import React, { useRef, useState } from 'react';
import { GoPlus } from 'react-icons/go';
import { MdEdit } from 'react-icons/md';

interface TeacherData {
    name: string;
    id: number;
}

interface GradeValueData {
    id: number;
    name: string;
}

interface AddOrModifyGradeModalProps {
    onSubmit: (formData: any) => Promise<void>;
    teachers: TeacherData[];
    gradeValues: GradeValueData[];
    subjectName?: string;
    grade?: {
        weight: number;
        gradeValueId: number;
        issuerId: number;
    };
}

export const AddOrModifyGradeModal: React.FC<AddOrModifyGradeModalProps> = ({
    teachers,
    gradeValues,
    onSubmit,
    subjectName,
    grade,
}) => {
    const [isModalOpen, setIsModalOpen] = useState(false);
    const formRef = useRef<FormInstance<any>>(null);

    return (
        <>
            <Button
                title={grade ? 'Modify grade' : 'Add grade'}
                icon={grade ? <MdEdit /> : <GoPlus />}
                onClick={() => setIsModalOpen(true)}
            />
            <Modal
                open={isModalOpen}
                onCancel={() => setIsModalOpen(false)}
                onOk={() => {
                    formRef.current?.submit();
                    setIsModalOpen(false);
                }}
                title={
                    subjectName
                        ? `Add grade for ${subjectName}`
                        : 'Modify grade'
                }
            >
                <Form
                    onFinish={onSubmit}
                    ref={formRef}
                    initialValues={
                        grade
                            ? {
                                  gradeValueId: grade.gradeValueId,
                                  weight: grade.weight,
                                  issuerId: grade.issuerId,
                              }
                            : undefined
                    }
                >
                    <Form.Item
                        label="Grade"
                        name="gradeValueId"
                    >
                        <Select
                            options={gradeValues.map(({ id, name }) => ({
                                label: name,
                                value: id,
                            }))}
                        />
                    </Form.Item>
                    <Form.Item
                        label="Weight"
                        name="weight"
                    >
                        <Slider
                            min={0.1}
                            max={5}
                            step={0.1}
                            defaultValue={1}
                        />
                    </Form.Item>
                    <Form.Item
                        label="Issuer"
                        name="issuerId"
                    >
                        <Select
                            options={teachers.map(({ id, name }) => ({
                                label: name,
                                value: id,
                            }))}
                            showSearch
                            filterOption={(input, option) =>
                                (option?.label ?? '')
                                    .toLowerCase()
                                    .includes(input.toLowerCase())
                            }
                        />
                    </Form.Item>
                </Form>
            </Modal>
        </>
    );
};
